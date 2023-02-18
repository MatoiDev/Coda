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


/*
 
 Order [Freelance]
 - id: String ✅
 - title: String ✅
 - description: String ✅
 - customerID: userID ✅
 - reward: String || Int ✅
 - topic: FreelanceTopic (enum) ✅
 - subTopic: FreelanceSubTopic.rawValue ✅
 - dateOfPublish: String ✅
 - responses: Int ✅
 - views: Int ✅
 - descriptors: [LangDescriptor] ✅
 - Core skills: [String] ✅
 - Files : [URL] ✅      ->      In Storage: FreelanceOrderFiles
 - imageExamplesURLs: [String] ✅    —>    In Storage: FreelanceOrdersExamples
 
 */


enum SpecifiedPriceType: String, CaseIterable, Identifiable {
    case perProject = "per project", perHour = "per hour"
    var id: Self { self }
}

extension View {
    func hookMBProgressHUD(isPresented: Binding<Bool>, progressInPercentages: Binding<Double>) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                MBProgressHUDRepresentable(percent: progressInPercentages, show: isPresented)
            }
        }
    }
}

struct OrderConstructor: View {
    
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    // Edit properties
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var reward: FreelanceOrderTypeReward = .negotiated
    @State private var price: String = ""
    @State private var pricePer: SpecifiedPriceType = .perHour
    @State private var topic: FreelanceTopic = .Development
    @State private var languageDescriptors: [LangDescriptor] = [LangDescriptor.defaultValue]
    @State private var selectedPDFs: [URL] = []
    
    @State private var devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic = .Offtop
    @State private var adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic = .Offtop
    @State private var designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic = .Offtop
    @State private var testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic = .Software
    
    @State private var topicPickerAlive: Bool = false // Закрывает линки для выбора подтопика
    
    @State private var descriptionTextFieldContentHeight: CGFloat = 600
    
    @State private var showPreviewDescription: Bool = false
    @State private var showDocumentPicker: Bool = false
    
    @State private var showPDFView: Bool = false
    @State private var pdfURLToOpen: URL?
    
    @State private var showLinkAlert: Bool = false
    @State private var TFAlertText: String? // Текст, который ввели в алерте
    @State private var stub: String?
    
    @State private var MBProgressHook: Bool = false
    @State private var MBProgressInPercentages: Double = 0
    
    @State private var showTLPhotosPicker: Bool = false
    @State private var selectedAssets: [TLPHAsset] = [TLPHAsset]() // Images
    
    @State private var coreSkills: String = ""
    
    let textAlertHandler : TextAlertHandler = TextAlertHandler.sharedInstance
    
    @ObservedObject private var fsmanager: FSManager = FSManager()
    @ObservedObject private var observeManager: FirebaseFilesUploadingProgreessManager = FirebaseFilesUploadingProgreessManager()

    
    var body: some View {
        List {
            // MARK: - Main Info sections
            // MARK: - Title
            Section {
                
                TextField(LocalizedStringKey("Order name"), text: self.$title)
                    .robotoMono(.semibold, 17)
                // MARK: - Description
                    
                MultilineListRowTextField("Order description", text: self.$description, alertTrigger: self.$showLinkAlert)
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
                        self.reward = .negotiated
                    } label: {
                        HStack {
                            Text("Сontractual price")
                        }
                    }
                    
                    Button {
                        self.reward = .specified(price: self.price)
                    } label: {
                        HStack {
                            Text("Specified price")
                            Spacer()
                            Image(systemName: "dollarsign")
                        }
                    }
                    
                } label: {
                    HStack {
                        Text(self.reward == FreelanceOrderTypeReward.negotiated ? "Сontractual price" : "Specified price")
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
                Text("Budget")
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
                }


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
                Text("Language Requirements")
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
            
            // MARK: - Files
            // MARK: - Files Picker
            if self.selectedPDFs.count < 3 {
                Section {
                    Button {
                        self.showDocumentPicker.toggle()
                    } label: {
                        RoundedRectangle(cornerRadius: 25).foregroundColor(Color.clear)
                            .frame(height: 150)
                            .overlay {
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 2, dash: [10], dashPhase: 4))
                            }
                            .overlay {
                                Image("RoseCloud")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                            }
                    }
                } header: {
                    Text("Files")
                        .robotoMono(.semibold, 20)
                        .foregroundColor(.white)
//                        .padding(.leading, 20)
                } footer: {
                    Text("Upload the ToR or other documents in .pdf format")
                }
                .textCase(nil)
                .listRowBackground(Color.clear)
    //            .listRowInsets(EdgeInsets.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                .buttonStyle(.plain)
            }
            Section {
                ForEach(self.selectedPDFs, id: \.self) { url in
                    if let attributes = url.fileAttributes {
                        Button {
                            self.pdfURLToOpen = url
                            self.showPDFView.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "doc.viewfinder")
                                        .resizable()
                                        .frame(width: 35, height: 35)
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(.primary)
                                
                                Text(attributes.name)
                                    .robotoMono(.semibold, 12)
                                    .frame(maxWidth: 120, maxHeight: 45)
                                    .lineLimit(1)
                                Spacer()
                                Text(attributes.extension)
                                        .foregroundColor(.secondary)
                                Spacer()
                                Text(Double(attributes.size).bytesToHumanReadFormat())
                                        .foregroundColor(.secondary)
                                        .robotoMono(.semibold, 13)
                            }.robotoMono(.semibold, 15)
                        }
                    }
                }
                .onDelete(perform: self.onDelete)
                .onMove(perform: self.onMove)
            } header: {
                if self.selectedPDFs.count == 3 {
                    Text("Files")
                        .robotoMono(.semibold, 20, color: .primary)
                }
            }.textCase(nil)
            
            Button {
                self.MBProgressHook.toggle()
                self.fsmanager.createFreelanceOrder(owner: self.loginUserID, name: self.title, description: self.description, priceType: self.reward, price: self.price, per: self.pricePer, topic: self.topic, devSubtopic: self.devSubtopic, adminSubtopic: self.adminSubtopic, designSubtopic: self.designSubtopic, testSubtopic: self.testSubtopic, languages: self.languageDescriptors, coreSkills: self.coreSkills, previews: self.assetsToImage(assets: self.selectedAssets), files: self.selectedPDFs, observeManager: self.observeManager) { res in
                    switch res {
                    case .success(let success):
                        print(success)
                    case .failure(_):
                        print("fail")
                    }
                }
            } label: {
                Text("Test")
            }

            
           Text("")
                .padding()
                .listRowBackground(Color.clear)
        }
        .hookMBProgressHUD(isPresented: self.$MBProgressHook, progressInPercentages: self.$observeManager.amountPercentage)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: self.coreSkills, perform: { string in
            if string.count(of: ",") > 9 && string.last! == "," {
                self.coreSkills = String(string.dropLast())
            }
        })
        .sheet(isPresented: self.$showDocumentPicker, content: {
            UIDocumentPickerViewControllerRepresentable(documentURLs: self.$selectedPDFs)
        })
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
        .sheet(isPresented: self.$showPDFView, content: {
            PDFWebViewControllerRepresentable(with: self.$pdfURLToOpen)
                .edgesIgnoringSafeArea(.all)
        })
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
    
    private func onDelete(offsets: IndexSet) {
        self.selectedPDFs.remove(atOffsets: offsets)
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        self.selectedPDFs.move(fromOffsets: source, toOffset: destination)
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






