//
// Created by Matoi on 22.01.2023.
//


import Combine
import Foundation

final class ArticlesViewModel: ObservableObject {
    var newsAPI = NewsAPI.shared

    @Published var indexEndpoint: Int
    @Published var searchString: String

    @Published var articles = [Article]()
    @Published var articlesError: NewsError?

    private var validString: AnyPublisher<String, Never> {
        $searchString
                .debounce(for: 0.1, scheduler: RunLoop.main)
                .removeDuplicates()
                .eraseToAnyPublisher()
    }

    init(index: Int = 0, text: String = "technology") {

        self.indexEndpoint = index
        self.searchString = text

        Publishers.CombineLatest( $indexEndpoint, validString)
                .setFailureType(to: NewsError.self)
                .flatMap {  (indexEndpoint, search) -> AnyPublisher<[Article], NewsError> in
                    if 3...30 ~= search.count {
                        self.articles = [Article]()
                        return self.newsAPI.fetchArticlesErr(from:
                        Endpoint( index: indexEndpoint, text: search)!)
                    } else {
                        return Just([Article]())
                                .setFailureType(to: NewsError.self)
                                .eraseToAnyPublisher()
                    }
                }
                .sink(receiveCompletion:  {[weak self] (completion) in
                            if case let .failure(error) = completion {
                                self?.articlesError = error
                            }},
                        receiveValue: { [weak self] in
                            self?.articles = $0
                        })
                .store(in: &self.cancellableSet)
    }
    private var cancellableSet: Set<AnyCancellable> = []
}
