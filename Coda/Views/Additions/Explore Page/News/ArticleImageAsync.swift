//
// Created by Matoi on 22.01.2023.
//

import SwiftUI

struct ArticleImageAsync: View {

    @ObservedObject var imageLoader: NewsImageLoader
    @State private var animateColor: CGFloat = 20

    var body: some View {
        Group {
            if !imageLoader.noData {
                ZStack {
                    if self.imageLoader.image != nil {
                        Image(uiImage: self.imageLoader.image!)
                                .resizable()
                                .scaledToFit()
                    } else {
                        if imageLoader.url != nil {
                            Rectangle()
                                .foregroundColor(Color(uiColor: UIColor(red: self.animateColor, green: self.animateColor, blue: self.animateColor, alpha: 1)))
                                    .frame(width: (UIScreen.main.bounds.width) * 0.75,
                                            height: UIScreen.main.bounds.width  * 0.6,
                                            alignment: .center)
                                    .scaledToFit()
                                    .onAppear {
                                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                                            self.animateColor = self.animateColor == 20 ? 50 : 20
                                        }
                                    }
                        } else {
                            EmptyView()
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
}

