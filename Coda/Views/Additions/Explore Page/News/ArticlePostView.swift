//
// Created by Matoi on 22.01.2023.
//

import SwiftUI


struct ArticlePostView: View {

    let article: Article

    init(of article: Article) {
        self.article = article
    }

    var body: some View {
        VStack {
            Text(self.article.title)
            if let imageURL: String = self.article.urlToImage {
                ArticleImageAsync(imageLoader: NewsImageLoader(url: URL(string: imageURL)))
            }
            
            Text(self.article.source.name ?? "") +
            Text(self.article.author ?? "")
                
            
        }
    }
}
