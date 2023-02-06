//
//  OrderConstructor.swift
//  Coda
//
//  Created by Matoi on 01.02.2023.
//

import SwiftUI
import UIKit


/*
 
 Order [Freelance]
 - id: String
 - title: String
 - description: String
 - customerID: userID
 - reward: String || Int
 - topic: FreelanceTopic (enum)
 - dateOfPublish: String
 - responses:  Int
 - views: Int
 - upvotes: Int
 - descriptors: [LangDescriptor]
 - imageExamplesURLs: [String]    —>    In Storage: FreelanceOrdersExamples
 
 */



struct OrderConstructor: View {
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var reward: FreelanceOrderTypeReward = .negotiated
    @State private var price: Int?
    @State private var topic: FreelanceTopic = .Development
    @State private var images: [UIImage]?
    
    @State private var descriptionTextFieldContentHeight: CGFloat = 600
    
    @State private var showPreviewDescription: Bool = false
    
    @State private var showLinkAlert: Bool = false
    @State private var TFAlertText: String? // Текст, который ввели в алерте
    @State private var stub: String?
    
    let textAlertHandler : TextAlertHandler = TextAlertHandler.sharedInstance
    
    var body: some View {
        List {
            Section {
                TextField("Title", text: self.$title)
                    .robotoMono(.semibold, 17)
            } header: {
                Text("Main Info")
                    .robotoMono(.semibold, 13)
            }.textCase(nil)
            
                Section {
                    MultilineListRowTextField("Description", text: self.$description, alertTrigger: self.$showLinkAlert, handledURL: self.$TFAlertText)
                        .robotoMono(.medium, 13)
                        .fixedSize(horizontal: false, vertical: true)
                } footer: {
                    HStack {
                        Button {
                            self.showPreviewDescription.toggle()
                        } label: {
                            Text("Preview")
                                .robotoMono(.medium, 12, color: .blue)
                        }
                        Spacer()
                        Text("\(self.description.count)/5000")
                            .robotoMono(.light, 12, color: .secondary)
                    }
                    
                }
            
           
           Text("")
                .padding()
                .listRowBackground(Color.clear)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("New Order")
                        .robotoMono(.semibold, 18)
                    Text("[Constructor]")
                        .robotoMono(.medium, 13, color: .secondary)
                }
                
            }
        }
        .textFieldAlert(isPresented: self.$showLinkAlert, content: {
            TextFieldAlert(title: "Add Link", message: "The link will be displayed as selected text.", text: self.$stub) { url in
                print(self.stub ?? "", url)
                self.TFAlertText = url
                self.textAlertHandler.url.send(url)
            }
        })
        .sheet(isPresented: self.$showPreviewDescription) {
            DescriptionPreview(text: self.description)
        }
        
    }
}
