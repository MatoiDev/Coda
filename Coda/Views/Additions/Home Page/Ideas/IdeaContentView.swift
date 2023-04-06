//
//  IdeaContentView.swift
//  Coda
//
//  Created by Matoi on 06.04.2023.
//



import SwiftUI
import Foundation
import Combine

// TODO: Настроить отображение уровня сложности, а так же рейтинга идеи.


struct IdeaContentView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showAuthorProfileView: Bool = false
    
    private let idea: Idea
    
    init(withIdea idea: Idea) {
        self.idea = idea
    }
    
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    // MARK: - Business card
                    Button {
                        self.showAuthorProfileView.toggle()
                    } label: {
                        BusinessCardAsync(withType: .author, userID: self.idea.author)
                            .padding(.horizontal)
                            .padding(.top)
                    }


                    
                    // MARK: - Title
                    
                    HStack {
                        Text(idea.title)
                            .robotoMono(.bold, 25)
                            .lineLimit(2)
                            .minimumScaleFactor(0.2)
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.leading, 24)
                    
                    
                    // MARK: - Tags
                    
                    WrappingHStack(tags: self.idea.languages + self.getTags(from: self.idea.skills))
                        .padding(.horizontal)
                    
                
//                    BusinessCard(type: .author, image: self.$imageLoader.image, error: self.$imageLoader.errorLog, firstName: self.userFirstName, lastName: self.userLastName, reputation: self.userReputation)
//                        .padding()
                    // MARK: - Date, comments & views
                    HStack(alignment: .center) {
                        Text(self.idea.dateOfPublish)
                            .padding(.leading, 24)
                            .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                    
                        Spacer()
                        HStack {
                            Text("\(self.idea.comments.count)")
                                .foregroundColor(.white)
                                .robotoMono(.medium, 14)
                            Image("chat")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
//                                .padding(.trailing)
                            Divider()
                            Text("\(self.idea.views.count)")
                                .foregroundColor(.white)
                                .robotoMono(.medium, 14)
                            Image(systemName: "eye")
                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                        }
                   
                        .padding(2)
                        .padding(.horizontal, 4)
                        .background(Color("BubbleMessageRecievedColor"), in: RoundedRectangle(cornerRadius: 30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(red: 0.80, green: 0.80, blue: 0.80), lineWidth: 1)
                        }
                        .padding(.trailing)
                        .padding(4)
                        .fixedSize()
                        
         
                    }.padding(.top, -8)
                    
                    // MARK: - Previews
                    if !self.idea.images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(self.idea.images, id: \.self) { imageURL in
                                    CachedImageView(with: imageURL, for: .Default)
                                        .scaledToFill()
                                        .frame(width: 250, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 25))
                            }
                        }.padding(.horizontal)
                        }.frame(height: 175)
                    }
                    
                    
                    // MARK: - Files
//                    if let files = self.idea.files, !self.idea.files.isEmpty {
//
//                        VStack {
//                            HStack {
//                                Text("Files")
//                                    .robotoMono(.semibold, 18, color: .secondary)
//                                    Spacer()
//                            }.padding(.horizontal, 8)
//                                .padding(.bottom, 4)
//                                .padding(.horizontal)
//                            HStack(alignment: .center, spacing: 8) {
//                                Spacer()
//                                    ForEach(files, id: \.self) { url in
//
//                                        if let file_Attr = url.fileAttributes {
//                                            VStack(alignment: .center) {
//
//                                                Image(systemName: "doc.viewfinder")
//                                                        .resizable()
//                                                        .frame(width: 45, height: 45)
//                                                        .symbolRenderingMode(.hierarchical)
//                                                        .foregroundColor(.primary)
//                                                        .padding(.top)
//                                                Spacer()
//                                                Text(file_Attr.name)
//                                                    .lineLimit(1)
//                                                    .padding(.horizontal)
//                                                    .robotoMono(.semibold, 13)
//
//                                                Text(Double(file_Attr.size).bytesToHumanReadFormat())
//                                                    .lineLimit(1)
//                                                    .padding(.horizontal)
//                                                    .robotoMono(.semibold, 10, color: .secondary)
//                                                    .padding(.bottom)
//
//                                            }
//                                            .frame(
//                                                width: UIScreen.main.bounds.width / 3.5,
//                                                height: UIScreen.main.bounds.width / 3.5
//                                            )
//                                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                                            .overlay {
//                                                RoundedRectangle(cornerRadius: 20)
//                                                    .stroke(Color.secondary, lineWidth: 4)
//                                            }
//                                        }
//
//
//                                }
//                                Spacer()
//                            }.padding(.horizontal)
//                        }
//                    }
                    
                
                    // MARK: - Text
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Idea Description")
                                .robotoMono(.semibold, 18, color: .secondary)
                                Spacer()
                        }.padding(.horizontal, 8)
                            .padding(.bottom, 4)
                     
                        Text(LocalizedStringKey(self.idea.text))
                    }
                    .padding(.horizontal)
                    
                    // TODO: - Here must be comments
                    // MARK: - Comments
                    
                    Text("")
                        .frame(height: 55)
                }
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AdditionDarkBackground"))
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: self.$showAuthorProfileView, content: {
            ProfileView(with: self.idea.author, dismissable: true)
    
        })
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("")
//            }
//        }
    }
      
    private func getTags(from string: String) -> [String] {
        return string.components(separatedBy: ", ")
    }
}


let TestIdea = Idea(id: "fdsafdas", author: "fdafdsa", title: "Написать замену Siri в виде горничной", text: "Кого только не бесит эта сфера, появившаяся ещё в 9 iOS? Хотелось бы иметь возможность убирать её, а так же ставить свои картинки из галереи. Если ещё реализуете возможность добавлять анимированные фотографии или видео - цены вам не будет!", category: FreelanceTopic.Development.rawValue, subcategory: FreelanceSubTopic.FreelanceDevelopingSubTopic.Offtop.rawValue, difficultyLevel: "Senior", skills: "iOS, jailbreak, Siri, AppCode, ARM-asm, gif", languages: [LangDescriptor.Logos.rawValue], images: [], files: [], time: 1244.1234, comments: [], stars: [], responses: [], views: [], saves: [], dateOfPublish: "6 Apr 09:31")

struct IdeaContentView_Previews: PreviewProvider {
    static var previews: some View {
        IdeaContentView(withIdea: TestIdea)
    }
}
