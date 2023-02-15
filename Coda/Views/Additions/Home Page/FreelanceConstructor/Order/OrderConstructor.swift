//
//  OrderConstructor.swift
//  Coda
//
//  Created by Matoi on 01.02.2023.
//

import SwiftUI
import UIKit
import TLPhotoPicker
import Combine
import Introspect



/*
 
 Order [Freelance]
 - id: String
 - title: String ✅
 - description: String ✅
 - customerID: userID
 - reward: String || Int ✅
 - topic: FreelanceTopic (enum) ✅
 - subTopic: FreelanceSubTopic.rawValue ✅
 - dateOfPublish: String
 - responses:  Int
 - views: Int
 - upvotes: Int
 - descriptors: [LangDescriptor] ✅
 - imageExamplesURLs: [String]    —>    In Storage: FreelanceOrdersExamples
 
 */


enum SpecifiedPriceType: String, CaseIterable, Identifiable {
    case perProject = "per project", perHour = "per hour"
    var id: Self { self }
}

struct OrderConstructor: View {
    
    // Edit properties
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var reward: FreelanceOrderTypeReward = .negotiated
    @State private var price: String = ""
    @State private var pricePer: SpecifiedPriceType = .perHour
    @State private var topic: FreelanceTopic = .Development
    @State private var languageDescriptors: [LangDescriptor] = [LangDescriptor.defaultValue]
    
    @State private var devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic = .Offtop
    @State private var adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic = .Offtop
    @State private var designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic = .Offtop
    @State private var testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic = .Software
    
    @State private var topicPickerAlive: Bool = false // Закрывает линки для выбора подтопика
    
    @State private var descriptionTextFieldContentHeight: CGFloat = 600
    
    @State private var showPreviewDescription: Bool = false
    
    @State private var showLinkAlert: Bool = false
    @State private var TFAlertText: String? // Текст, который ввели в алерте
    @State private var stub: String?
    
    @State private var showTLPhotosPicker: Bool = false
    @State private var selectedAssets: [TLPHAsset] = [TLPHAsset]() // Images
    
    let textAlertHandler : TextAlertHandler = TextAlertHandler.sharedInstance
    
    
    var body: some View {
        List {
            // MARK: - Main Info sections
            // MARK: - Title
            Section {
                
                TextField("Title", text: self.$title)
                    .robotoMono(.semibold, 17)
            } header: {
                HStack {
                    Text("Main Info")
                        .robotoMono(.semibold, 20)
                    Spacer()
                }
                
            }.textCase(nil)
            // MARK: - Description
                Section {
                    MultilineListRowTextField("Description", text: self.$description, alertTrigger: self.$showLinkAlert)
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
            // MARK: - Previews
            // MARK: - Photos Picker
            Section {
                if !self.selectedAssets.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<(self.selectedAssets.count >= 3 ? 3 : self.selectedAssets.count + 1), id: \.self) { assetIndex in
                            Button {
                                self.showTLPhotosPicker.toggle()
                            } label: {
                                
                                    if let asset = self.selectedAssets[safe: assetIndex],
                                       let image: UIImage = asset.fullResolutionImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                        
                                    } else {
                                        ZStack {
                                            Color(red: 0.11, green: 0.11, blue: 0.12)
                                            Image(systemName: "plus.circle.fill")
                                                .resizable()
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundColor(.primary)
                                                .frame(width: 50, height: 50)
                                        }
                                        
                                    }
                                
                            }
                            .frame(width: 250, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                    }.padding(.leading)
                    }.frame(height: 175)
                }
         

            } header: {
                HStack {
                    Text("Previews")
                        .robotoMono(.semibold, 20)
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                    Spacer()
                    if self.selectedAssets.count < 3 {
                        Button {
                            self.showTLPhotosPicker.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color("Register2"))
                                .frame(width: 20, height: 20)
                                .font(.system(size: 20).bold())
                                
                        }
                    }
                   
                    
                }
            }
            .textCase(nil)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets.init(top: 8, leading: 0, bottom: 8, trailing: 0))
            .buttonStyle(.plain)
            
            // MARK: - Reward
            Section {
                Menu {
                    
                    Button {
                        self.reward = .negotiated
                    } label: {
                        HStack {
                            Text("Contractual")
                        }
                    }
                    
                    Button {
                        self.reward = .specified(price: self.price)
                    } label: {
                        HStack {
                            Text("Specified")
                            Spacer()
                            Image(systemName: "dollarsign")
                        }
                    }
                    
                } label: {
                    HStack {
                        Text(self.reward == FreelanceOrderTypeReward.negotiated ? "Contractual" : "Specified")
                            .robotoMono(.semibold, 15)
                        Spacer()
                        Image(systemName: "contextualmenu.and.cursorarrow")
                        
                            .resizable()
                            .scaledToFit()
                            .symbolRenderingMode(.hierarchical)
                            .frame(height: 20)
                            .foregroundColor(.primary)
                            .font(.system(size: 12).bold())
                
                    }
                }
                if self.reward != .negotiated {
                    HStack {
                        TextField("0", text: self.$price)
                            .foregroundColor(".,".contains(self.price[safe: self.price.startIndex] ?? "1") ? Color.red : Color.white)
                            .robotoMono(.semibold, 17)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.none)
                        Divider()
                        Picker(selection: self.$pricePer) {
                            Text(LocalizedStringKey("per hour")).tag(SpecifiedPriceType.perHour)
                            Text(LocalizedStringKey("per project")).tag(SpecifiedPriceType.perProject)
                                .robotoMono(.semibold, 15)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.01)
                        } label: {
                        }.fixedSize(horizontal: true, vertical: false)

                    }
                    
                }
             

            } header: {
                Text("Reward")
                    .robotoMono(.semibold, 20)
                    .foregroundColor(.white)
            }.textCase(nil)
            
            Section  {
              
                NavigationLink(isActive: self.$topicPickerAlive) {
                    FreelanceTopicPicker(topic: self.$topic,
                                         isPickerAlive: self.$topicPickerAlive,
                                         devSubtopic: self.$devSubtopic,
                                         adminSubtopic: self.$adminSubtopic,
                                         designSubtopic: self.$designSubtopic,
                                         testSubtopic: self.$testSubtopic)
                } label: {
                    switch self.topic {
                    case .Administration:
                        Group {
                            Text(LocalizedStringKey(self.topic.rawValue)) + Text(": ") + Text(LocalizedStringKey(self.adminSubtopic.rawValue))
                        }.robotoMono(.semibold, 15)
                       
                    case .Testing:
                        Group {
                            Text(LocalizedStringKey(self.topic.rawValue)) + Text(": ") + Text(LocalizedStringKey(self.testSubtopic.rawValue))
                        }.robotoMono(.semibold, 15)
                       
                    case .Development:
                        Group {
                        Text(LocalizedStringKey(self.topic.rawValue)) + Text(": ") + Text(LocalizedStringKey(self.devSubtopic.rawValue))
                    }.robotoMono(.semibold, 15)
                    case .Design:
                        Group {
                        Text(LocalizedStringKey(self.topic.rawValue)) + Text(": ") + Text(LocalizedStringKey(self.designSubtopic.rawValue))
                        }.robotoMono(.semibold, 15)
                    }
                }


            }
            
            Section {
                NavigationLink {
                    LanguageDescriptorPicker(langDescriptors: self.$languageDescriptors)
                } label: {
                    
                    Text(self.getLineFromDescriptors(self.languageDescriptors))
                        .robotoMono(.semibold, 14, color: .white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        
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
        .fullScreenCover(isPresented: self.$showTLPhotosPicker) {
            TLPhotosPickerViewControllerRepresentable(assets: self.$selectedAssets)
        } 
    }
    
    private func getLineFromDescriptors(_ descriptors: [LangDescriptor]) -> String {
        var rawedDescriptors: [String] = []
        for descriptor in descriptors {
            rawedDescriptors.append(descriptor.rawValue)
        }
        if rawedDescriptors.count == 1 {
            return rawedDescriptors[0]
        } else if rawedDescriptors.count == 2 {
            return "\(rawedDescriptors[0]) and \(rawedDescriptors[1])"
        } else if rawedDescriptors.count == 3 {
            return "\(rawedDescriptors[0]), \(rawedDescriptors[1]) and \(rawedDescriptors[2])"
        }
    return rawedDescriptors[..<3].joined(separator: ", ") + " and \(rawedDescriptors.count - 3) more"
        
        
    }
}
