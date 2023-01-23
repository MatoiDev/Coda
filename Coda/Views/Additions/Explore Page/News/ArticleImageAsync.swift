//
// Created by Matoi on 22.01.2023.
//

import SwiftUI

struct ArticleImageAsync: View {

    @ObservedObject var imageLoader: NewsImageLoader
    @State private var animate = false

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
                                    .foregroundColor(.gray)
                                    .frame(width: (UIScreen.main.bounds.width) * 0.75,
                                            height: UIScreen.main.bounds.width  * 0.6,
                                            alignment: .center)
                                    .scaledToFit()
                                    .overlay(
                                            HStack {
                                                ProgressView()
                                                Text("Loading...")
                                                        .font(.footnote)
                                                        .foregroundColor(.white)
                                                        .rotationEffect(Angle(degrees: animate ? 60 : -60))
                                                        .onAppear {
                                                            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever()) {
                                                                self.animate = true
                                                            }
                                                        }
                                            }

                                    )
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

