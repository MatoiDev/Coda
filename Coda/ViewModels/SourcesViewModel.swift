//
// Created by Matoi on 22.01.2023.
//

import Foundation

//
//  SourcesViewModelErr.swift
//  NewsApp
//
//  Created by Tatiana Kornilova on 09/02/2020.
//  Copyright © 2020 Tatiana Kornilova. All rights reserved.
//

import Combine
import Foundation

final class SourcesViewModelErr: ObservableObject {
    var newsAPI = NewsAPI.shared

    @Published var searchString: String = ""
    @Published var country: String = "us"

    @Published var sources = [Source]()
    @Published var sourcesError: NewsError?

    private var validString:  AnyPublisher<String, Never> {
        $searchString
                .debounce(for: 0.1, scheduler: RunLoop.main)
                .removeDuplicates()
                .eraseToAnyPublisher()
    }
    init() {
        Publishers.CombineLatest( $country,  validString)
                .setFailureType(to: NewsError.self)
                .flatMap {  (country, search) ->
                        AnyPublisher<[Source], NewsError> in
                    return self.newsAPI.fetchSourcesErr(for: country)
                            .map{search == "" ? $0 : $0.filter {
                                ($0.name?.lowercased().contains(search.lowercased()))!}}
                            .eraseToAnyPublisher()
                }
                .sink(
                        receiveCompletion:  {[unowned self] (completion) in
                            if case let .failure(error) = completion {
                                self.sourcesError = error
                            }},
                        receiveValue: { [unowned self] in
                            self.sources = $0
                        })
                .store(in: &self.cancellableSet)
    }
    private var cancellableSet: Set<AnyCancellable> = []
}
