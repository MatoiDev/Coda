//
//  FindTeamConstructor.swift
//  Coda
//
//  Created by Matoi on 08.03.2023.
//

import SwiftUI
import TLPhotoPicker

/*
    Team Finder
 
 - id: String
 - author: userID
 
 - (e) category: ScopeTopic ++
 - (e) subTopic: Subtopic +
 - (e) title: String ++
 - (e) text: String ++
 - (e) images: UIImage -> IdeaImages ++
 - (e) languages: LangDescriptor ++
 - (e) requiredSkills: [String] ++
 - (e) recruitsCount: Int // Необходимое количество сокомандников
 
 - recruited: [userID] // Список набранных пользователей

 - comments: [commentID]
 - views: [userID]
 
 - dateOfPublish: String
 
 */


// TODO: - Идея поиска команды
/*
    Пользователь заходит в объявление, нажимает на кнопку "Предложить сотрудничество",
    У автора есть возможность принять приглашение (которое будет находится у него в чате), тогда id пользователя добавляется в recruited,
    В объявлении увиличивается количество набранных пользователей [k/n] - где k — уже набранные,
    n - необходимое количество для набора.
    Так же автор имеет возможность отказать заявке, в данном случае все счётчики остаются в прежднем положении, а пользователю прийдёт уведомление о том, что его заявка отклонена.
    
 
 */

struct FindTeamConstructor: View {
    
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
    
    @State private var languageDescriptors: [LangDescriptor] = [LangDescriptor.defaultValue]
    
    @State private var recruitsCount: Int = 1
    
    @State private var selectedAssets: [TLPHAsset] = [TLPHAsset]() // Images
    @State private var coreSkills: String = ""


    // Show triggers
    @State private var showPreviewDescription: Bool = false /// Вызвать окно предпросмотра введённого  текста идеи
    @State private var showDocumentPicker: Bool = false
    @State private var showTLPhotosPicker: Bool = false
    @State private var showLinkAlert: Bool = false
    @State private var showTeamFinderPreview: Bool = false
    
    
    // Store
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
            
            // MARK: - Number of teammates
            
            Section {
                Stepper("\(self.recruitsCount)", value: self.$recruitsCount, in: 1...15)
                    .robotoMono(.medium, 15)
            } header: {
                Text("Number Of Teammates")
                    .robotoMono(.semibold, 20)
                    .foregroundColor(.white)
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
                Text("Skills")
                    .robotoMono(.semibold, 20)
                    .foregroundColor(.white)
            } footer: {
                Text("Enter from 1 to 10 skills, separating them with a comma")
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
                    self.showTeamFinderPreview.toggle()
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
                        isActive: self.$showTeamFinderPreview,
                        destination: {
                            FindTeamPreview(title: self.title, text: self.text, category: self.category, devSubtopic: self.devSubtopic, adminSubtopic: self.adminSubtopic, designSubtopic: self.designSubtopic, testSubtopic: self.testSubtopic, recruitsCount: self.recruitsCount, languages: self.languageDescriptors, coreSkills: self.coreSkills, previews: self.assetsToImage(assets: self.selectedAssets), imageLoader: FirebaseTemporaryImageLoaderVM(with: URL(string: self.loginUserID)), doneTrigger: self.$doneUploading, rootViewIsActive: self.$rootViewIsActive)
                        },
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
                    Text("Find Team")
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

struct FindTeamConstructor_Previews: PreviewProvider {
    static var previews: some View {
        FindTeamConstructor(rootViewIsActive: .constant(true))
    }
}
