//
//  FirebaseAvatarImageServer.swift
//  Coda
//
//  Created by Matoi on 03.04.2023.
//

import SwiftUI
import Combine

class FirebaseAvatarImageServer: ObservableObject {
    
    private func fetchedImageHandler(data: Data?, response: URLResponse?) throws -> UIImage {
        guard let data = data,
           let image = UIImage(data: data),
           let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else { throw URLError(.cannotParseResponse) }
        return image
    }
    
    func getImageFromServer(imageURL url: URL) -> AnyPublisher<UIImage, Error> {
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(self.fetchedImageHandler)
            .eraseToAnyPublisher()
    }
}


