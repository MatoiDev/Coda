//
//  CellImageView.swift
//  Coda
//
//  Created by Matoi on 25.12.2022.
//

import SwiftUI
import Foundation
import Cachy
import Combine
import Kingfisher

enum ImageType {
    case Cell
    case ChatIntelocutorLogo
    case Message
    case CellMessage
}

//enum ImageDataConverter: String {
//    case DataConvertFailure = "The data is not suitable for conversion to an image."
//}
//
//fileprivate class ImageFetcher: ObservableObject {
//
//    private let loader = CachyLoader()
//
//    private func loadImageFromCachy(withURL url: URL, completionHandler: @escaping (_ returnedData: UIImage?, _ error: Error?) -> ()) {
////        self.loader.load
//        self.loader.loadWithURL(url, isRefresh: true, expirationDate: ExpiryDate.never.date) { data, _ in
//            if let image = UIImage(data: data) {
//                completionHandler(image, nil)
//            } else {
//                completionHandler(nil, ImageDataConverter.DataConvertFailure.rawValue)
//            }
//
//        }
//    }
//
//    func fetchImageFuture(url: URL) -> Future<UIImage, Error> {
//        Future { promise in
//            self.loadImageFromCachy(withURL: url) { returnedData, error in
//                if let error = error {
//                    promise(.failure(error))
//                } else {
//                    promise(.success(returnedData!))
//                }
//
//            }
//
//        }
//    }
//
//}
//
//fileprivate class GetImageViewModel: ObservableObject {
//    @Published var image: UIImage?
//    let fetcher: ImageFetcher = ImageFetcher()
//    let url: URL
//
//    var cancellabels = Set<AnyCancellable>()
//
//    init(withURL url: URL) {
//        self.url = url
////        self.getImage()
//    }
//
//
//    func getImage() {
//
//        self.fetcher.fetchImageFuture(url: self.url)
//
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//            } receiveValue: { [weak self] uiimage in
//                self?.image = uiimage
//            }
//            .store(in: &cancellabels)
//
//
//
//
//    }
//}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.secondary.opacity(0.5),
                    lineWidth: 3
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.primary,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)

        }
    }
}


struct ChatCachedImageView: View {
    @ObservedObject var urlImageModel: CachedImageModel
    
    var type: ImageType
    let urlString: String
    
    init(with urlString: String?, for type: ImageType) {
        self.urlImageModel = CachedImageModel(urlString: urlString)
        self.urlString = urlString ?? "https://firebasestorage.googleapis.com/v0/b/com-erast-coda.appspot.com/o/DefaultImage%2F8d7e9d76ab83277382d33925fa9e4aca.png?alt=media&token=ad231de0-5ea9-46fc-aafe-62d024163492"
        self.type = type
    }
    
    func updateImage(url: String) {
        self.urlImageModel.update(withURL: url)
    }
    
    
    var body: some View {

            if self.type == .Message {
                KFImage
                    .url(URL(string: self.urlString))
                    
                    .placeholder({ progress in
                        CircularProgressView(progress: progress.fractionCompleted)
                            .fixedSize()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if self.type == .CellMessage {
                KFImage
                    .url(URL(string: self.urlString))
                    .placeholder({ progress in
                        CircularProgressView(progress: progress.fractionCompleted)
                            .fixedSize()
                    })
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(width: 20, height: 20)
            }
            else {
                KFImage
                    .url(URL(string: self.urlString))
                    
                    .placeholder({ progress in
                        CircularProgressView(progress: progress.fractionCompleted)
                            .fixedSize()
                    })
                    .resizable()
                    .clipShape(Circle())
            }

    }
    static var defaultImage = UIImage(named: "default")
}
