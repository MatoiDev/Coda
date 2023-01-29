//
// Created by Matoi on 22.01.2023.
//

import Foundation
import Combine

struct APIConstants {
//    static let apiKey: String = "2cd60ff51c87439789f42a2c312fc56d"t
    static let apiKey: String = "ad18028a33f94d0b9874ccce9efd22b3"

    static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateStyle = .medium
        return formatter
    }()
}

enum Endpoint {
    case topHeadLines
    case articlesFromCategory(_ category: String)
    case articlesFromSource(_ source: String)
    case search (searchFilter: String)
    case sources (country: String)

    var baseURL:URL {URL(string: "https://newsapi.org/v2/")!}

    func path() -> String {
        switch self {
        case .topHeadLines, .articlesFromCategory:
            return "top-headlines"
        case .search,.articlesFromSource:
            return "everything"
        case .sources:
            return "sources"
        }
    }

    var absoluteURL: URL? {
        let queryURL = baseURL.appendingPathComponent(self.path())
        let components = URLComponents(url: queryURL, resolvingAgainstBaseURL: true)
        guard var urlComponents = components else {
            return nil
        }
        switch self {
        case .topHeadLines:
            urlComponents.queryItems = [URLQueryItem(name: "country", value: region),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
            ]
        case .articlesFromCategory(let category):
            urlComponents.queryItems = [URLQueryItem(name: "country", value: region),
                                        URLQueryItem(name: "category", value: category),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
            ]
        case .sources (let country):
            urlComponents.queryItems = [URLQueryItem(name: "country", value: country),
                                        URLQueryItem(name: "language", value: countryLang[country]),
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
            ]
        case .articlesFromSource (let source):
            urlComponents.queryItems = [URLQueryItem(name: "sources", value: source),
                                        /*  URLQueryItem(name: "language", value: locale),*/
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
            ]
        case .search (let searchFilter):
            urlComponents.queryItems = [URLQueryItem(name: "q", value: searchFilter.lowercased()),
                                        /*URLQueryItem(name: "language", value: locale),*/
                                        /* URLQueryItem(name: "country", value: region),*/
                                        URLQueryItem(name: "apikey", value: APIConstants.apiKey)
            ]
        }
        return urlComponents.url
    }

    var locale: String {
        return  Locale.current.languageCode ?? "en"
    }

    var region: String {
        return  Locale.current.regionCode?.lowercased() ?? "us"
    }

    init? (index: Int, text: String = "technology") {
        switch index {
        case 0: self = .topHeadLines
        case 1: self = .search(searchFilter: text)
        case 2: self = .articlesFromCategory(text)
        case 3: self = .articlesFromSource(text)
        case 4: self = .sources (country: text)
        default: return nil
        }
    }

    var countryLang : [String: String]  {
        [
            "ar": "es",  // argentina
            "au": "en",  // australia
            "br": "es",  // brazil
            "ca": "en",  // canada
            "cn": "cn",  // china
            "de": "de",  // germany
            "es": "es",  // spain
            "fr": "fr",  // france
            "gb": "en",  // unitedKingdom
            "hk": "cn",  // hongKong
            "ie": "en",  // ireland
            "in": "en",  // india
            "is": "en",  // iceland
            "il": "he",  // israil for sources - language
            "it": "it",  // italy
            "nl": "nl",  // netherlands
            "no": "no",  // norway
            "ru": "ru",  // russia
            "sa": "ar",  // saudiArabia
            "us": "en",  // unitedStates
            "za": "en"   // southAfrica
        ]
    }
}



protocol APIProtocol {
    func fetch<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error>
}



class NewsAPI: APIProtocol {

    static let shared = NewsAPI()

    private var subscriptions = Set<AnyCancellable>()

    // Асинхронная выборка на основе URL с сообщениями об ошибках
    func fetch<T: Decodable>(_ url: URL) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)             
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          200...299 ~= httpResponse.statusCode else {
                        throw NewsError.responseError(
                                ((response as? HTTPURLResponse)?.statusCode ?? 500,
                                        String(data: data, encoding: .utf8) ?? ""))
                    }
                    return data
                }
                .decode(type: T.self, decoder: APIConstants.jsonDecoder)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }

    func fetchSourcesErr(for country: String) ->
            AnyPublisher<[Source], NewsError>{
        Future<[Source], NewsError> { [unowned self] promise in
            guard let url = Endpoint.sources(country: country).absoluteURL  else {
                return promise(
                        .failure(.urlError(URLError(.unsupportedURL))))
            }
            self.fetch(url)
                    .tryMap { (result: SourcesResponse) -> [Source] in
                        result.sources }
                    .sink(
                            receiveCompletion: { (completion) in
                                if case let .failure(error) = completion {
                                    switch error {
                                    case let urlError as URLError:
                                        promise(.failure(.urlError(urlError)))
                                    case let decodingError as DecodingError:
                                        promise(.failure(.decodingError(decodingError)))
                                    case let apiError as NewsError:
                                        promise(.failure(apiError))
                                    default:
                                        promise(.failure(.genericError))
                                    }
                                }
                            },
                            receiveValue: { promise(.success($0)) })
                    .store(in: &self.subscriptions)
        }.eraseToAnyPublisher()
    }

    func fetchArticlesErr(from endpoint: Endpoint) -> AnyPublisher<[Article], NewsError> {
        Future<[Article], NewsError> { [unowned self] promise in
            guard let url = endpoint.absoluteURL else {
                promise(.failure(.urlError(URLError(.unsupportedURL))))
                return
            }
            self.fetch(url)
                    .tryMap { (result: NewsResponse) -> [Article] in
                        result.articles
                    }
                    .sink(receiveCompletion: { (completion) in
                        switch completion {
                        case .failure(let error):
                            switch error {
                            case let urlError as URLError:
                                promise(.failure(.urlError(urlError)))
                            case let decodingError as DecodingError:
                                promise(.failure(.decodingError(decodingError)))
                            case let apiError as NewsError:
                                promise(.failure(apiError))
                            default:
                                promise(.failure(.genericError))
                            }
                        case .finished:
                            print("Finished")
                        }
                    }, receiveValue: { promise(.success($0)) })
                    .store(in: &self.subscriptions)
        }.eraseToAnyPublisher()
    }



}
