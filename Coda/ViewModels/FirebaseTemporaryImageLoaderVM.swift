//
//  FirebaseTemporaryImageLoaderVM.swift
//  Coda
//
//  Created by Matoi on 03.04.2023.
//

import SwiftUI
import Combine

class FirebaseTemporaryImageLoaderVM: ObservableObject {
   
   @Published var image: UIImage?
   @Published var errorLog: String?
   
   private var server: FirebaseAvatarImageServer = FirebaseAvatarImageServer()
   
   var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
   
   init(with url: URL?) {
       self.fetchImage(for: url)
   }
   
   private func fetchImage(for url: URL?) -> Void {
       if let url = url {
           server.getImageFromServer(imageURL: url)
               .receive(on: DispatchQueue.main)
               .sink { completion in
                   switch completion {
                   case .finished:
                       self.errorLog = nil
                   case .failure(let err):
                       self.errorLog = err.localizedDescription
                       self.image = nil
                   }
               } receiveValue: { [weak self] image in
                   self?.image = image
               }
               .store(in: &self.cancellables)
       } else {
           self.errorLog = URLError(.badURL).localizedDescription
       }
      

   }
}

