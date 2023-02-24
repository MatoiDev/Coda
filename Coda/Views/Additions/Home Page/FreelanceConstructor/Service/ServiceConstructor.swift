//
//  ServiceConstructor.swift
//  Coda
//
//  Created by Matoi on 24.02.2023.
//

import SwiftUI
import UIKit
import TLPhotoPicker
import Combine
import Introspect

/*
 Service [Freelance]
 
 - id
 - title: String
 - description: String
 - executorID: userID
 - salary: Int || String
 - topic: FreelanceTopic (enum)
 - subtopic: FreelanceSubtopic
 - dateOfPublish: String
 - requests:  Int
 - views: Int
 - upvotes: Int
 - descriptors: [LangDescriptor]
 - Core skills: [String]
 - imageExamplesURLs: [String]    —>    In Storage: FreelanceServicesExamples
 
 */

struct ServiceConstructor: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    @Binding var rootViewIsActive: Bool
    
    // Edit properties
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var salaryType: FreelancePriceType = .negotiated
    @State private var salary: String = ""
    @State private var pricePer: SpecifiedPriceType = .perHour
    @State private var topic: FreelanceTopic = .Development
    @State private var languageDescriptors: [LangDescriptor] = [LangDescriptor.defaultValue]
    
    
    @State private var devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic = .Offtop
    @State private var adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic = .Offtop
    @State private var designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic = .Offtop
    @State private var testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic = .Software
    
    @State private var topicPickerAlive: Bool = false // Закрывает линки для выбора подтопика
    
    
    @State private var showPreviewDescription: Bool = false
    @State private var showDocumentPicker: Bool = false
    
    @State private var showLinkAlert: Bool = false // Алерт для вызова филда под ссылку
    @State private var TFAlertText: String? // Текст, который ввели в алерте
    @State private var stub: String? // В текст, изменяемый алертом, в данном view используется Future-Promise, так что оставлю заглушкой
    
    @State private var showServicePreview: Bool = false
    
    @State private var showTLPhotosPicker: Bool = false
    @State private var selectedAssets: [TLPHAsset] = [TLPHAsset]() // Images
    
    @State private var coreSkills: String = ""
    
    let textAlertHandler : TextAlertHandler = TextAlertHandler.sharedInstance
    
    @State var doneUploading: Bool = false // Закрыть конструктор при успешной загрузке заказа
    @Environment(\.dismiss) var dissmiss
    
    
    private func areAllFormsCompleted() -> Bool {

        if self.salaryType == .negotiated {
            return (!self.title.isEmpty && !self.description.isEmpty &&
                    !self.coreSkills.isEmpty)
        }
        return (!self.title.isEmpty && !self.description.isEmpty && !self.coreSkills.isEmpty && self.salary.isCorrect())
        
    }
 
    
    var body: some View {
        List {
            // MARK: - Main Info sections
            // MARK: - Title
            Section {
                
                TextField(LocalizedStringKey("Service name"), text: self.$title)
                    .robotoMono(.semibold, 17)
                // MARK: - Description
                    
                MultilineListRowTextField("Service description", text: self.$description, alertTrigger: self.$showLinkAlert)
                    .robotoMono(.medium, 13)
                    .offset(x: -4)
                    .fixedSize(horizontal: false, vertical: true)
                    
            } header: {
                HStack {
                    Text("Main Info")
                        .robotoMono(.semibold, 20)
                    Spacer()
                }
                
            } footer: {
                HStack {
                    Button {
                        self.showPreviewDescription.toggle()
                    } label: {
                        Text("Preview")
                            .robotoMono(.medium, 12, color: .cyan)
                    }
                    Spacer()
                    Text("\(self.description.count)/5000")
                        .robotoMono(.light, 12, color: .secondary)
                }
                
            }.textCase(nil)
            
            // MARK: - Reward
            Section {
                Menu {
                    
                    Button {
                        self.salaryType = .negotiated
                    } label: {
                        HStack {
                            Text("Сontractual price")
                        }
                    }
                    
                    Button {
                        self.salaryType = .specified(price: self.salary)
                    } label: {
                        HStack {
                            Text("Specified price")
                            Spacer()
                            Image(systemName: "dollarsign")
                        }
                    }
                    
                } label: {
                    HStack {
                        Text(self.salaryType == FreelancePriceType.negotiated ? "Сontractual price" : "Specified price")
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
                if self.salaryType != .negotiated {
                    HStack {
//                        TextFieldWithDisabledPasting(text: self.$price, placeHolder: "0")
                        TextField("0", text: self.$salary)
                            .foregroundColor(self.salary.isCorrect() ? Color.white : Color.red)
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
                Text("Сost Of Service")
                    .robotoMono(.semibold, 20)
                    .foregroundColor(.white)
            }.textCase(nil)
            
            
            // MARK: - Topic Picker
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
                }.isDetailLink(false)


            } header: {
                HStack {
                    Text("Scope Of Activity")
                        .robotoMono(.semibold, 20)
                    Spacer()
                }
                
            }.textCase(nil)
            
            // MARK: - Language Section
            Section {
                NavigationLink {
                    LanguageDescriptorPicker(langDescriptors: self.$languageDescriptors)
                } label: {
                    
                    Text(self.getLineFromDescriptors(self.languageDescriptors))
                        .robotoMono(.semibold, 14, color: .white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        
                }
                
            } header: {
                Text("Languages used")
                    .robotoMono(.semibold, 20)
                    .foregroundColor(.white)
            }.textCase(nil)
            
            Section {
                
                    ZStack(alignment: .leading) {
                        if self.coreSkills.isEmpty {
                            Text(LocalizedStringKey("MVVM, Firebase, ..."))
                                .robotoMono(.semibold, 14, color: Color(red: 0.36, green: 0.36, blue: 0.36))
                                .padding(.horizontal, 4)
                        }
                        
                        TextEditor(text: self.$coreSkills)
                            .robotoMono(.semibold, 14)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                    }
                
                
            } header: {
                Text("Сore Skills")
                    .robotoMono(.semibold, 20)
                    .foregroundColor(.white)
            } footer: {
                Text("Enter from 1 to 10 key skills, separating them with a comma")
            }
            .textCase(nil)
            
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
            
            
            // MARK: - Preview Button
            Section {
                Button {
                    self.showServicePreview.toggle()
                } label: {
                    Text("Save")
                        .robotoMono(.bold, 20, color: .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color("AdditionDarkBackground"))
                      
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                .overlay(
                    
                    NavigationLink(
                        isActive: self.$showServicePreview,
                        destination: { ServicePreview(title: self.title, description: self.description, priceType: self.salaryType, price: self.salary, per: self.pricePer, topic: self.topic, devSubtopic: self.devSubtopic, adminSubtopic: self.adminSubtopic, designSubtopic: self.designSubtopic, testSubtopic: self.testSubtopic, languages: self.languageDescriptors, coreSkills: self.coreSkills, previews: self.assetsToImage(assets: self.selectedAssets), imageLoader: FirebaseTemporaryImageLoaderVM(with: URL(string: avatarURL)), doneTrigger: self.$doneUploading, rootViewIsActive: self.$rootViewIsActive) },
                        label: { EmptyView() }
                            
                    )
                    .isDetailLink(false)
                    .disabled(!self.areAllFormsCompleted())
                    .opacity(0)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LinearGradient(colors: [self.areAllFormsCompleted() ? Color("Register2") : Color(red: 0.3, green: 0.3, blue: 0.3), self.areAllFormsCompleted() ? .cyan : Color(red: 0.8, green: 0.8, blue: 0.8)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                }
                .disabled(!self.areAllFormsCompleted())
                .listRowBackground(Color.clear)
            }
         

            
           Text("")
                .padding()
                .listRowBackground(Color.clear)
        }
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: self.coreSkills, perform: { string in
            if string.count(of: ",") > 9 && string.last! == "," {
                self.coreSkills = String(string.dropLast())
            }
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("New Service")
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
    
    private func assetsToImage(assets: [TLPHAsset]) -> [UIImage] {
        var images: [UIImage] = []
        for asset in assets {
            if let image = asset.fullResolutionImage {
                images.append(image)
            }
            
        }
        return images
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
