//
//  IdeaConstructorMain.swift
//  Coda
//
//  Created by Matoi on 01.03.2023.
//

#warning ("IdeaConstructorMain.swift: TODO")

// TODO: Сделать систему оценивания сложности идеи DifficultyLevel
// TODO: Добавить разделы для создания коммерческих идей; Настроить оплату

/*
    Idea
 
 - id: String
 - author: userID
 
 - (e) category: ScopeTopic ++
 - (e) title: String ++
 - (e) text: String // Сама идея ++
 - (e) difficultyLevel: IdeaDifficultyLevel +
 - (e) images: UIImage -> IdeaImages +
 - (e) files: Files -> IdeaFiles ++
 - (e) languages: LangDescriptor ++
 - (e) skills: [String] ++

 - upvotes: Int
 - downvotes: Int
 - comments: [commentID]
 - views: [userID]
 
 - dateOfPublish: String
 
 
 */


import SwiftUI
import TLPhotoPicker


enum IdeaDifficultyLevel: String {
    
    case all = "All Levels"
    
    case newbie = "Newbie"
    case intern = "Intern"
    case junior = "Junior"
    case middle = "Middle"
    case senior = "Senior"
    case lead = "Lead"
    
}

struct IdeaConstructorMain: View {

    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    // Live cycle
    @Binding var rootViewIsActive: Bool
    @State private var topicPickerAlive: Bool = false // Закрывает линки для выбора подтопика

    // Edit properties
    @State private var title: String = ""
    @State private var text: String = ""
    
    @State private var category: FreelanceTopic = .Development
    @State private var devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic = .Offtop
    @State private var adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic = .Offtop
    @State private var designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic = .Offtop
    @State private var testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic = .Software
    
    @State private var difficultyLevel: IdeaDifficultyLevel = .middle
    
    @State private var languageDescriptors: [LangDescriptor] = [LangDescriptor.defaultValue]
    @State private var selectedPDFs: [URL] = []
    
    @State private var selectedAssets: [TLPHAsset] = [TLPHAsset]() // Images
    @State private var coreSkills: String = ""


    // Show triggers
    @State private var showPreviewDescription: Bool = false /// Вызвать окно предпросмотра введённого  текста идеи
    @State private var showDocumentPicker: Bool = false
    @State private var showTLPhotosPicker: Bool = false
    @State private var showPDFView: Bool = false
    @State private var showLinkAlert: Bool = false
    @State private var showIdeaPreview: Bool = false
    
    
    // Store
    @State private var pdfURLToOpen: URL?
    @State private var TFAlertText: String? // Текст, который ввели в алерте
    @State private var stub: String?


    let textAlertHandler : TextAlertHandler = TextAlertHandler.sharedInstance

    @State var doneUploading: Bool = false // Закрыть конструктор при успешной загрузке заказа
    @Environment(\.dismiss) var dissmiss


    private func areAllFormsCompleted() -> Bool {
        return (!self.title.isEmpty && !self.text.isEmpty && !self.coreSkills.isEmpty)
    }


    var body: some View {
        List {
            // MARK: - Main Info sections
            // MARK: - Title
            Section {

                TextField(LocalizedStringKey("Title"), text: self.$title)
                    .robotoMono(.semibold, 17)
                // MARK: - text

                MultilineListRowTextField("Description", text: self.$text, alertTrigger: self.$showLinkAlert)
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
                    Text("\(self.text.count)/5000")
                        .robotoMono(.light, 12, color: .secondary)
                }

            }.textCase(nil)



            // MARK: - Category Picker
            Section  {

                NavigationLink(isActive: self.$topicPickerAlive) {
                    ScopeTopicPickerExtended(topic: self.$category,
                                         isPickerAlive: self.$topicPickerAlive,
                                         devSubtopic: self.$devSubtopic,
                                         adminSubtopic: self.$adminSubtopic,
                                         designSubtopic: self.$designSubtopic,
                                         testSubtopic: self.$testSubtopic)
//                    ScopeTopicPicker(topic: self.$category, isPickerAlive: self.$topicPickerAlive)
                } label: {
                    switch self.category {
                    case .Administration:
                        Group {
                            Text(LocalizedStringKey(self.category.rawValue)) + Text(": ") + Text(LocalizedStringKey(self.adminSubtopic.rawValue))
                        }.robotoMono(.medium, 15)
                        
                    case .Testing:
                        Group {
                            Text(LocalizedStringKey(self.category.rawValue)) + Text(": ") + Text(LocalizedStringKey(self.testSubtopic.rawValue))
                        }.robotoMono(.medium, 15)
                        
                    case .Development:
                        Group {
                            Text(LocalizedStringKey(self.category.rawValue)) + Text(": ") + Text(LocalizedStringKey(self.devSubtopic.rawValue))
                        }.robotoMono(.medium, 15)
                    case .Design:
                        Group {
                            Text(LocalizedStringKey(self.category.rawValue)) + Text(": ") + Text(LocalizedStringKey(self.designSubtopic.rawValue))
                        }.robotoMono(.medium, 15)
                    case .all:
                        Group {
                            Text(LocalizedStringKey(self.category.rawValue)) + Text(": ") + Text(LocalizedStringKey("All"))
                        }.robotoMono(.medium, 15)
                        
                    }
                }.isDetailLink(false)

            } header: {
                HStack {
                    Text("Category")
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
                            Text(LocalizedStringKey("Node.js, Realm, ..."))
                                .robotoMono(.semibold, 14, color: Color(red: 0.36, green: 0.36, blue: 0.36))
                                .padding(.horizontal, 4)
                        }

                        TextEditor(text: self.$coreSkills)
                            .robotoMono(.semibold, 14)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                    }


            } header: {
                Text("Skills & Tools")
                    .robotoMono(.semibold, 20)
                    .foregroundColor(.white)
            } footer: {
                Text("Enter from 1 to 10 skills or tools, separating them with a comma")
            }
            .textCase(nil)
            
            // MARK: - Difficulty Level
            Section {
                Menu {
                    if self.difficultyLevel != .newbie {
                        Button {
                            self.difficultyLevel = .newbie
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(IdeaDifficultyLevel.newbie.rawValue))
//                                Spacer()
//                                Image(IdeaDifficultyLevel.newbie.rawValue)
                            }
                        }
                    }
                    if self.difficultyLevel != .intern {
                        Button {
                            self.difficultyLevel = .intern
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(IdeaDifficultyLevel.intern.rawValue))
//                                Spacer()
//                                Image(IdeaDifficultyLevel.intern.rawValue)
                            }
                        }
                    }
                    if self.difficultyLevel != .junior {
                        Button {
                            self.difficultyLevel = .junior
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(IdeaDifficultyLevel.junior.rawValue))
//                                Spacer()
//                                Image(IdeaDifficultyLevel.junior.rawValue)
                            }
                        }
                    }
                    if self.difficultyLevel != .middle {
                        Button {
                            self.difficultyLevel = .middle
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(IdeaDifficultyLevel.middle.rawValue))
//                                Spacer()
//                                Image(IdeaDifficultyLevel.middle.rawValue)
                            }
                        }
                    }
                    if self.difficultyLevel != .senior {
                        Button {
                            self.difficultyLevel = .senior
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(IdeaDifficultyLevel.senior.rawValue))
//                                Spacer()
//                                Image(IdeaDifficultyLevel.senior.rawValue)
                            }
                        }
                    }
                    if self.difficultyLevel != .lead {
                        Button {
                            self.difficultyLevel = .lead
                        } label: {
                            HStack {
                                Text(LocalizedStringKey(IdeaDifficultyLevel.lead.rawValue))
//                                Spacer()
//                                Image(IdeaDifficultyLevel.lead.rawValue)
                            }
                        }
                    }
                    

                } label: {
                    HStack {
                        Text(LocalizedStringKey(self.difficultyLevel.rawValue))
                            .robotoMono(.medium, 15)
                        Spacer()
//                        Image(self.difficultyLevel.rawValue)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 25)
                        Text("")
                    }
             
                }
            } header: {
                Text("Difficulty Level")
                    .robotoMono(.semibold, 20)
            } footer: {
                Text("How would you rate the complexity of your Idea?")
            }.textCase(nil)

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
                                LottieView(named: "uploadToCloud3", loop: true)

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

            // MARK: - Preview Button
            Section {
                Button {
                    self.showIdeaPreview.toggle()
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
                        isActive: self.$showIdeaPreview,
                        destination: { IdeaPreview(title: self.title, text: self.text, category: self.category, devSubtopic: self.devSubtopic, adminSubtopic: self.adminSubtopic, designSubtopic: self.designSubtopic, testSubtopic: self.testSubtopic, difficultyLevel: self.difficultyLevel, languages: self.languageDescriptors, coreSkills: self.coreSkills, previews: self.selectedAssets.compactMap({ $0.fullResolutionImage }), files: self.selectedPDFs, imageLoader: FirebaseTemporaryImageLoaderVM(with: URL(string: self.loginUserID)), doneTrigger: self.$doneUploading, rootViewIsActive: self.$rootViewIsActive) },
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
        .sheet(isPresented: self.$showDocumentPicker, content: {
            UIDocumentPickerViewControllerRepresentable(documentURLs: self.$selectedPDFs)
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("New Idea")
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
            DescriptionPreview(text: self.text)
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
        guard rawedDescriptors.count > 0 else { return "None" }
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

struct IdeaConstructorMain_Previews: PreviewProvider {
    static var previews: some View {
        IdeaConstructorMain(rootViewIsActive: .constant(true))
        
    }
}
