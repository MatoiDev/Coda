//
// Created by Matoi on 22.01.2023.
//

import Foundation

import UIKit
import Combine

class NewsImageCacher {
    static let shared = NewsImageCacher()
    var loaders: NSCache<NSString, NewsImageLoader> = NSCache()

    func loaderFor(article: Article) -> NewsImageLoader {
        let key = NSString(string: "\(article.title)")
        if let loader = loaders.object(forKey: key) {
            return loader
        } else {
            let url = (article.urlToImage != nil && article.urlToImage != "null")
                    ? URL(string: article.urlToImage!)
                    : nil
            let loader = NewsImageLoader (url: url)
            loaders.setObject(loader, forKey: key)
            return loader
        }
    }
}

final class NewsImageLoader: ObservableObject {

    @Published var url: URL?

    @Published var image: UIImage?
    @Published var noData = false // Если не комбайн не может загрузить

    init(url: URL?) {
        self.url = url
        $url
                .setFailureType(to: Error.self)
                .flatMap { (url) -> AnyPublisher<UIImage?, Error> in
                    self.fetchImageErr(for: url).eraseToAnyPublisher()
                }
                .sink(receiveCompletion:  {[unowned self] (completion) in
                    if case .failure(_) = completion {
                        self.noData = true
                    }},
                        receiveValue: { [unowned self] in
                            self.image = $0
                        })
                .store(in: &self.cancellableSet)
    }

    // выборка изображения UIImage? с учетом ошибок
    func fetchImageErr(for  url: URL?) -> AnyPublisher<UIImage?, Error>{
        Future<UIImage?, Error> { [unowned self] promise in

            guard let url = url, !self.noData  else {
                return promise(
                        .failure(URLError(.unsupportedURL)))
            }
            URLSession.shared.dataTaskPublisher(for: url)
                    .tryMap { (data, response) -> Data in
                        guard let httpResponse = response as? HTTPURLResponse,
                              200...299 ~= httpResponse.statusCode else {
                            throw URLError(.unsupportedURL) as Error
                        }
                        return data
                    }
                    .map { UIImage(data: $0) }
                    .receive(on: RunLoop.main)
                    .sink(
                            receiveCompletion: { (completion) in
                                if case let .failure(error) = completion {
                                    promise(.failure(error))
                                }
                            },
                            receiveValue: { promise(.success($0)) })
                    .store(in: &self.cancellableSet)
        }
                .eraseToAnyPublisher()
    }

    private var cancellableSet: Set<AnyCancellable> = []
}


