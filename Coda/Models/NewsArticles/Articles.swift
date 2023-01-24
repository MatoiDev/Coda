//
// Created by Matoi on 22.01.2023.
//

import Foundation

struct NewsResponse: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let author: String?
    let urlToImage: String?
    let publishedAt: Date?
    let source: Source
    let url: String?
}

extension Article {
    static let SOLID = Article(title: "Test article",
                               description: "testing..",
                               author: "Matoi",
                               urlToImage: nil,
                               publishedAt: nil,
                               source: Source(id: nil,
                                              name: nil,
                                              description: nil,
                                              country: nil,
                                              category: nil,
                                              url: nil),
                               url: "https://google.com")
}

struct SourcesResponse: Codable {
    let status: String
    let sources: [Source]
}

struct Source: Codable,Identifiable {
    let id: String?
    let name: String?
    let description: String?
    let country: String?
    let category: String?
    let url: String?
}
