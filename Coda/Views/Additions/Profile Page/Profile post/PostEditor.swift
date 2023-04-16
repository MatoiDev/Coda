//
//  PostEditor.swift
//  Coda
//
//  Created by Matoi on 11.12.2022.
//

import SwiftUI

struct PostEditor: View {
    
    @State private var showImagePicker: Bool = false
    
    @State private var showingAlert = false
    @State private var alertLog = ""
    
    // animation properties
    @State private var rotation: Double = 0
    @State private var opacity: CGFloat = 1
    @State private var scale: CGFloat = 1
    
    // Working stuff
    @Binding var postBody: String
    @Binding var postImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                // MARK: - Text Editor
                TextEditor(text: self.$postBody)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                
                // MARK: - Image
                if let image: UIImage = self.postImage {
                    Image(uiImage: image)
                        .resizable()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .frame(maxWidth: .infinity)
                        .scaledToFit()
                        .padding()
                        
                        .overlay(alignment: .topTrailing) {
                            Button {
                                withAnimation(Animation.easeIn(duration: 0.2)) {
                                    self.rotation = 30
                                    self.opacity = 0
                                    self.scale = 0.2
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    self.postImage = nil
                                    self.opacity = 1
                                    self.rotation = 0
                                    self.scale = 1
                                }
                            } label: {
                                Image(systemName: "xmark.circle")
                                    
                                    .foregroundColor(.primary)
                                    .background(Color.secondary)
                                    .font(.system(size: 25))
                                    .clipShape(Circle())
                                    .padding(24)
                            }

                        }
                        .rotationEffect(Angle(degrees: self.rotation))
                        .opacity(self.opacity)
                        .scaleEffect(self.scale)
                }
                Spacer()
                Divider()
                    .frame(maxWidth: UIScreen.main.bounds.width - 20)
                HStack {
                    Spacer()
                    Button {
                        self.showImagePicker.toggle()
                    } label: {
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                            .font(.system(size: 25))
                    }
                }
                .padding(4)
            }
            if self.postBody.isEmpty {
                Text("Your text here...")
                    .robotoMono(.semibold, 16, color: .secondary)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 8)
                    .padding(.horizontal, 7)
            }
            
            
        }
        .sheet(isPresented: self.$showImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { result in
                switch result {
                case .success(let img):
                    self.postImage = img
                case .failure(let err):
                    self.alertLog = err.localizedDescription
                    self.showingAlert.toggle()
                }
            }
        }
        .robotoMono(.semibold, 16)
            .padding(.horizontal)
       
            .alert(alertLog, isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
        
    }
        
}
//
//struct PostEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        PostEditor()
//    }
//}
