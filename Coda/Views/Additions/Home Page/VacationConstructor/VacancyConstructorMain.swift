//
//  VacancyConstructorMain.swift
//  Coda
//
//  Created by Matoi on 25.02.2023.
//

/* Данный контроллер будет доступен только для аккаунтов компаний */

import SwiftUI
import UIKit
import TLPhotoPicker
import Combine
import Introspect

// TODO: Сделать 2 типа аккаунта, для компаний и для физических лиц.

/*
 
 
 Vacancy
 
 - id: String
 - (e) title: String +
 - (e) description: String +
 - (e) specialization: ScopeTopic (enum) +
 - (e) qualification: DeveloperQualificationType (enum) +
 - (e) Location: String +
 - (e) TypeOfEmployment: String +
 
 - (e) Requirements: [String] { Языки, гражданство и т д } +
 

 
 - (e) currency: CurrencyType (enum) +
 - (e) salary: Int || String +
 - (e) Languages: [LangDescriptor] +
 
 - (e) LinkToCompany: String? + [В настройках ЮР. аккаунта]
 - (e) email: String? + [В настройках ЮР. аккаунта]
 
 - dateOfPublish: String
 - views: Int


 */

enum TypeOfEmployment: String {
    case FullTime = "Full-Time"
    case PartTime = "Part-Time"
    case Temporary = "Temporary"
    case Seasonal = "Seasonal"
}

enum DeveloperQualificationType: String {
    case Intern = "Intern"
    case Junior = "Junior"
    case Middle = "Middle"
    case Senior = "Senior"
    case Lead = "Lead"
}

enum CurrencyType: String {
    case dollar = "Dollar"
    case ruble = "Ruble"
    case euro = "Euro"
}

enum LocationType: Equatable {
    case free
    case specified
}

enum SalaryType: String {
    
    case сontractual = "Contractual"
    case specified = "Specified"
    
}

struct VacancyConstructorMain: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    
    @Binding var rootViewIsActive: Bool
    
    // Edit properties
    // _____________________________________________________________________________________
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var specialization: FreelanceTopic = .Development
    @State private var qualification: DeveloperQualificationType = .Intern
    
    @State private var locationType: LocationType = .free
    @State private var specifiedLocation: String = "Москва, Москва, Центральный"
    
    @State private var typeOfEmployment: TypeOfEmployment = .FullTime
    
    @State private var salaryType: SalaryType = .сontractual
    @State private var currency: CurrencyType = .ruble
    @State private var salaryLowerBound: String = "" // Цена с
    @State private var salaryUpperBound: String = "" // Цена до
    @State private var requirements: String = ""
    @State private var languageDescriptors: [LangDescriptor] = [LangDescriptor.defaultValue]
    // _____________________________________________________________________________________
    @State private var topicPickerAlive: Bool = false // Закрывает линки для выбора подтопика
    
    @State private var showPreviewDescription: Bool = false

    @State private var showLinkAlert: Bool = false // Алерт для вызова филда под ссылку
    @State private var TFAlertText: String? // Текст, который ввели в алерте
    @State private var stub: String? // В текст, изменяемый алертом, в данном view используется Future-Promise, так что оставлю заглушкой
    
    @State private var showServicePreview: Bool = false
    
    
    let textAlertHandler : TextAlertHandler = TextAlertHandler.sharedInstance
    
    @State var doneUploading: Bool = false // Закрыть конструктор при успешной загрузке заказа
    @Environment(\.dismiss) var dissmiss
    
    
    private func areAllFormsCompleted() -> Bool {
        
        if self.salaryType == .specified {
            return (!self.title.isEmpty &&
                    !self.description.isEmpty &&
                    !self.requirements.isEmpty &&
                    self.salaryLowerBound.isCorrect() &&
                    self.salaryLowerBound.isCorrect())
        }
        return (!self.title.isEmpty &&
               !self.description.isEmpty &&
               !self.requirements.isEmpty)
    
        
    }
 
    
    var body: some View {
        List {
            // MARK: - Main Info sections
            // MARK: - Title
            Section {
                TextField(LocalizedStringKey("Vacancy name"), text: self.$title)
                    .robotoMono(.semibold, 17)
                // MARK: - Description
                    
                MultilineListRowTextField("Vacancy description", text: self.$description, alertTrigger: self.$showLinkAlert)
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
            
            // MARK: - Specialization Picker
            Section  {
              
                NavigationLink(isActive: self.$topicPickerAlive) {
                    ScopeTopicPicker(topic: self.$specialization, isPickerAlive: self.$topicPickerAlive)
                } label: {
                    
                    Text(LocalizedStringKey(self.specialization.rawValue))
                        .robotoMono(.medium, 15)
                }.isDetailLink(false)

            } header: {
                HStack {
                    Text("Specialization")
                        .robotoMono(.semibold, 20)
                    Spacer()
                }
                
            }.textCase(nil)
            
            // MARK: - Qualification
            
            Section {
                Menu {
                    
                    Button {
                        self.qualification = .Intern
                    } label:  {
                        Text(LocalizedStringKey(DeveloperQualificationType.Intern.rawValue))
                    }
                    Button {
                        self.qualification = .Junior
                    } label:  {
                        Text(LocalizedStringKey(DeveloperQualificationType.Junior.rawValue))
                    }
                    Button {
                        self.qualification = .Middle
                    } label:  {
                        Text(LocalizedStringKey(DeveloperQualificationType.Middle.rawValue))
                    }
                    Button {
                        self.qualification = .Senior
                    } label:  {
                        Text(LocalizedStringKey(DeveloperQualificationType.Senior.rawValue))
                    }
                    Button {
                        self.qualification = .Lead
                    } label:  {
                        Text(LocalizedStringKey(DeveloperQualificationType.Lead.rawValue))
                    }
                    
                } label: {
                    HStack {
                        Text(LocalizedStringKey(self.qualification.rawValue))
                            .robotoMono(.medium, 15)
                        Spacer()
                        Image("qualification")
                            .resizable()
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(height: 20)
                    }
       
                }
            } header: {
                Text("Qualification")
                    .robotoMono(.semibold, 20)
            }.textCase(nil)
            
            // MARK: - Location And Type Of Employment
            Section {
                // Location
                Menu {
                    Button {
                        
                        self.locationType = .free
                    } label: {
                        HStack {
                            Text(LocalizedStringKey("Can work remotely"))
                            Spacer()
                            Image("RemoteWorkFemale")
                        }
                        
                    }
                    
                    Button {
                        self.locationType = .specified
                    } label: {
                        HStack {
                            Text(LocalizedStringKey("Office work"))
                            Spacer()
                            Image("Office")
                        }
                    }
                } label: {
                    HStack {
                        Text(LocalizedStringKey(self.locationType == .free ? "Can work remotely" : "Office work"))
                            .robotoMono(.medium, 15)
                        Spacer()
                        Image(self.locationType == .free ? "RemoteWorkFemale" : "Office")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                            .foregroundColor(.white)
                    }
                    
                }
                /*
                Picker(selection: self.$locationType) {
                    Text(LocalizedStringKey("Can work remotely")).tag(LocationType.free)
                    Text(LocalizedStringKey("Office work")).tag(LocationType.specified)
                } label: {}
                 */
                if self.locationType == .specified {
                    NavigationLink {
                        RussianCityPicker(city: self.$specifiedLocation)
                    } label: {
                        Text(self.specifiedLocation)
                    }
                }
               

            } header: {
                Text("Location")
                    .robotoMono(.semibold, 20)
            }.textCase(nil)
            
            Section {
                // Type Of Employment
                Menu {
                    Button {
                        self.typeOfEmployment = .FullTime
                    } label: {
                        Text(LocalizedStringKey(TypeOfEmployment.FullTime.rawValue))
                            .robotoMono(.medium, 15)
                    }
                    
                    Button {
                        self.typeOfEmployment = .PartTime
                    } label: {
                        Text(LocalizedStringKey(TypeOfEmployment.PartTime.rawValue))
                            .robotoMono(.medium, 15)
                    }
                    
                    Button {
                        self.typeOfEmployment = .Temporary
                    } label: {
                        Text(LocalizedStringKey(TypeOfEmployment.Temporary.rawValue))
                            .robotoMono(.medium, 15)
                    }
                    
                    Button {
                        self.typeOfEmployment = .Seasonal
                    } label: {
                        Text(LocalizedStringKey(TypeOfEmployment.Seasonal.rawValue))
                            .robotoMono(.medium, 15)
                    }
                } label: {
                    HStack  {
                        Text(LocalizedStringKey(self.typeOfEmployment.rawValue))
                            .robotoMono(.medium, 15)
                        Spacer()
                        Image("OfficeWorker")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                            .foregroundColor(.white)
                    }
                
                }
                
                
//                Picker(selection: self.$typeOfEmployment) {
//
//                    Text(LocalizedStringKey(TypeOfEmployment.FullTime.rawValue)).tag(TypeOfEmployment.FullTime)
//                    Text(LocalizedStringKey(TypeOfEmployment.PartTime.rawValue)).tag(TypeOfEmployment.PartTime)
//                    Text(LocalizedStringKey(TypeOfEmployment.Temporary.rawValue)).tag(TypeOfEmployment.Temporary)
//                    Text(LocalizedStringKey(TypeOfEmployment.Seasonal.rawValue)).tag(TypeOfEmployment.Seasonal)
//                    Text(LocalizedStringKey(TypeOfEmployment.Leased.rawValue)).tag(TypeOfEmployment.Leased)
//
//                } label: {}
               
               

            } header: {
                Text("Type Of Employment")
                    .robotoMono(.semibold, 20)
            }.textCase(nil)
            
            
         
            
            


            
            // MARK: - Requirements
            Section {
                NavigationLink {
                    LanguageDescriptorPicker(langDescriptors: self.$languageDescriptors)
                } label: {
                    if self.languageDescriptors == [LangDescriptor.defaultValue] || self.languageDescriptors.isEmpty {
                        Text("Languages")
                            .robotoMono(.medium, 15, color: .white)
                    } else {
                        Text(self.getLineFromDescriptors(self.languageDescriptors))
                            .robotoMono(.medium, 15, color: .white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                    }
         
                        
                }
                
                    ZStack(alignment: .leading) {
                        if self.requirements.isEmpty {
                            Text(LocalizedStringKey("SCRUM, Jira ..."))
                                .robotoMono(.semibold, 14, color: Color(red: 0.36, green: 0.36, blue: 0.36))
                                .padding(.horizontal, 4)
                        }
                        
                        TextEditor(text: self.$requirements)
                            .robotoMono(.semibold, 14)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                    }
                
                
            } header: {
                Text("Requirements")
                    .robotoMono(.semibold, 20)
                    .foregroundColor(.white)
            } footer: {
                Text("Enter from 1 to 10 requirements, separating them with a comma")
            }
            .textCase(nil)
            
            // MARK: - Salary
            Section {
                Menu {
                    
                    Button {
                        self.salaryType = .сontractual
                    } label: {
                        HStack {
                            Text("Contractual salary")
                            Spacer()
                            Image("Handshake")
                                .resizable()
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button {
                        self.salaryType = .specified
                    } label: {
                        HStack {
                            Text("Specified salary")
                            Spacer()
                            Image("buxx")
                        }
                    }
                    
                } label: {
                    HStack {
                        Text(self.salaryType == .сontractual ? "Contractual salary" : "Specified salary")
                            .robotoMono(.semibold, 15)
                        Spacer()
                        Image(self.salaryType == .сontractual ? "Handshake" : "buxx")
                            .resizable()
                            .foregroundColor(.white)
                            .scaledToFit()
                            .frame(height: 20)
                        
                
                    }
                }
                if self.salaryType == .specified {
                    HStack {
                        TextField("From:", text: self.$salaryLowerBound)
                            .foregroundColor(self.salaryLowerBound.isCorrect() ? Color.white : Color.red)
                            .robotoMono(.semibold, 17)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.none)
                        TextField("To:", text: self.$salaryUpperBound)
                            .foregroundColor(self.salaryUpperBound.isCorrect() ? Color.white : Color.red)
                            .robotoMono(.semibold, 17)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.none)
        
                        Divider()
                        Picker(selection: self.$currency) {
                            
                            Text(LocalizedStringKey("Ruble")).tag(CurrencyType.ruble)
                                .robotoMono(.medium, 15)
                            Text(LocalizedStringKey("Dollar")).tag(CurrencyType.dollar)
                                .robotoMono(.medium, 15)
                            Text(LocalizedStringKey("Euro")).tag(CurrencyType.euro)
                                .robotoMono(.medium, 15)
                            
                        } label: {
                        }
                       
                        .robotoMono(.medium, 15)
                        .fixedSize(horizontal: true, vertical: false)

                    }
                    
                }
             

            } header: {
                Text("Salary")
                    .robotoMono(.semibold, 20)
                    .foregroundColor(.white)
            } footer: {
                Text("You can leave the \"To:\" field empty")
            }
            .textCase(nil)
        
            
            // MARK: - Contact details
            /// Будет браться из данных юр. аккаунта
//            Section {
//                TextField("Email", text: self.$email)
//                    .robotoMono(.medium, 15)
//                    .autocorrectionDisabled(true)
//                    .autocapitalization(.none)
//                TextField("Link to web", text: self.$companyLink)
//                    .robotoMono(.medium, 15)
//                    .autocorrectionDisabled(true)
//                    .autocapitalization(.none)
//            } header: {
//                Text(LocalizedStringKey("Contact Details"))
//                    .robotoMono(.semibold, 20)
//            }.textCase(nil)
            
            
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
                        destination: { VacancyPreview(title: self.title, description: self.description, specialization: self.specialization, qualification: self.qualification, locationType: self.locationType, specifiedLocation: self.specifiedLocation, typeOfEmployment: self.typeOfEmployment, salaryType: self.salaryType, currency: self.currency, salaryLowerBound: self.salaryLowerBound, salaryUpperBound: self.salaryUpperBound, requirements: self.requirements, languageDescriptors: self.languageDescriptors, imageLoader: FirebaseTemporaryImageLoaderVM(with: URL(string: loginUserID)), doneUploading: self.$doneUploading, rootViewIsActive: self.$rootViewIsActive) },
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
        .onChange(of: self.requirements, perform: { string in
            if string.count(of: ",") > 9 && string.last! == "," {
                self.requirements = String(string.dropLast())
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




//struct VacancyConstructorMain_Previews: PreviewProvider {
//    static var previews: some View {
//        VacancyConstructorMain()
//    }
//}
