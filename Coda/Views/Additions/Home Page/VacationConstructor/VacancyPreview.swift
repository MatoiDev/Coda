//
//  VacancyPreview.swift
//  Coda
//
//  Created by Matoi on 28.02.2023.
//

import SwiftUI

struct VacancyPreview: View {
    
    @AppStorage("LoginUserID") var loginUserID: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    
    var title: String
    var description: String
    var specialization: FreelanceTopic
    var qualification: DeveloperQualificationType
    var locationType: LocationType
    var specifiedLocation: String
    var typeOfEmployment: TypeOfEmployment
    var salaryType: SalaryType
    var currency: CurrencyType
    var salaryLowerBound: String
    var salaryUpperBound: String
    var requirements: String
    var languageDescriptors: [LangDescriptor]
    
   
    
    @StateObject var imageLoader: FirebaseTemporaryImageLoaderVM
    
    @Binding var doneUploading: Bool
    @Binding var rootViewIsActive: Bool
    
    @State private var MBProgressHook: Bool = false
    @State private var MBProgressInPercentages: Double = 0
    
    private let currentDate: String = Date().today(format: "dd MMMM yyyy, HH:mm")
    private let responsesCount = 11000
    private let viewsCount = 115000
    
    @Environment(\.dismiss) var dissmiss
    
    @ObservedObject private var fsmanager: FSManager = FSManager()
    @ObservedObject private var observeManager: FirebaseFilesUploadingProgreessManager = FirebaseFilesUploadingProgreessManager()
    
    init(title: String, description: String, specialization: FreelanceTopic, qualification: DeveloperQualificationType, locationType: LocationType, specifiedLocation: String, typeOfEmployment: TypeOfEmployment, salaryType: SalaryType, currency: CurrencyType, salaryLowerBound: String, salaryUpperBound: String, requirements: String, languageDescriptors: [LangDescriptor], imageLoader: FirebaseTemporaryImageLoaderVM, doneUploading: Binding<Bool>, rootViewIsActive: Binding<Bool>) {
        
        self._imageLoader = StateObject(wrappedValue: imageLoader)
        
        self.title = title
        self.description = description
        self.specialization = specialization
        self.qualification = qualification
        self.locationType = locationType
        self.specifiedLocation = specifiedLocation
        self.typeOfEmployment = typeOfEmployment
        self.salaryType = salaryType
        self.currency = currency
        self.salaryLowerBound = salaryLowerBound
        self.salaryUpperBound = salaryUpperBound
        self.requirements = requirements
        self.languageDescriptors = languageDescriptors
        
        self._doneUploading = doneUploading
        self._rootViewIsActive = rootViewIsActive
        
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    // MARK: - Title
                    
                    HStack {
                        Text(title)
                            .robotoMono(.bold, 25)
                            .lineLimit(2)
                            .minimumScaleFactor(0.2)
                        Spacer()
                    }
                    .padding([.leading, .top], 24)

                    
                    // MARK: - Price type
                    
                    HStack {
                        if salaryType == .сontractual {
                            Text("Contractual salary")
                        } else {
                            HStack {
                                if self.salaryUpperBound.isEmpty {
                                    Text("From: ")
                                        .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                                    + Text("\(Int(self.salaryLowerBound)!)")
                                } else {
                                    Text("From: ")
                                        .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8)) + Text(self.salaryLowerBound) + Text("  To: ")
                                        .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8)) + Text(self.salaryUpperBound)
                                      
                                }
                                Image(self.currency == .ruble ? "ruble.circle" : self.currency == .dollar ? "dollar.circle" : "euro.circle")
                                    .resizable()
//                                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.8))
                                    .foregroundStyle(LinearGradient(colors: [Color("Register2"), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .padding(.leading, 4)
                            }
                       
                        }
                        
                    }
                    .robotoMono(.medium, 15, color: Color.mint)
                    .padding(.leading, 24)
                    .padding(.top, 2)
                    
                    
                   
                    
                    
                    
                    // MARK: - Qualification and Type Of Employment
                    
                    HStack {
                        Spacer()
                        Image("diploma3")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                        Text(self.qualification.rawValue)
                             
                        Spacer()
                        Image("clock.blue.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                        Text(self.typeOfEmployment.rawValue)
                        Spacer()
                    }
                    .robotoMono(.medium, 15)
                    .padding(.horizontal)
                    
                    
       
                    
                    // MARK: - Tags
                    WrappingHStack(tags: self.languageDescriptors.compactMap {
                        $0 == LangDescriptor.defaultValue ? nil : $0.rawValue
                    } + self.getTags(from: self.requirements))
                        .padding(.horizontal)
                    

                    
               
                    
                    
                    // MARK: - Business card
                    
                    BusinessCard(type: .company, image: self.$imageLoader.image, error: self.$imageLoader.errorLog, firstName: self.userFirstName, lastName: self.userLastName, reputation: self.userReputation)
                        .padding()
                    
                    // MARK: - Date, responses & views
                    HStack(alignment: .center) {
                        Text(self.currentDate)
                            .padding(.leading, 24)
                            .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                    
                        Spacer()
                        HStack {
                            Text("\(self.responsesCount)")
                                .foregroundColor(.white)
                                .robotoMono(.medium, 14)
                            Image(systemName: "person.wave.2")
                                .robotoMono(.light, 12, color: Color(red: 0.80, green: 0.80, blue: 0.80))
                                .padding(.trailing)
                            Text("\(self.viewsCount)")
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
                    
                    // MARK: - Location
                      HStack {
                          
                          if self.locationType == .free {
                              Image(systemName: "circlebadge.fill")
                              Text("Can work remotely")
                                  
                              Image("RemoteWorkFemale")
                                  .resizable()
                                  .scaledToFit()
                                  .frame(height: 45)
                          } else {
                          
                              Text(self.specifiedLocation)
                              Image("Office")
                                  .resizable()
                                  .scaledToFit()
                                  .frame(height: 20)
                          }
                          
                      }
                      .padding(.leading, 24)
//                      .padding(.vertical, -8)
//                      .padding(.top, -8)
                      .robotoMono(.medium, 15)
        
                    
                    // MARK: - Description
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Vacancy Description")
                                .robotoMono(.semibold, 18, color: .secondary)
                                Spacer()
                        }.padding(.horizontal, 8)
                            .padding(.bottom, 4)
                     
                        Text(LocalizedStringKey(self.description))
                    }
                    .padding(.horizontal)

     
                    
                    // MARK: - Deploy Button
                    HStack {
                        Spacer()
                        Button {
                            self.MBProgressHook.toggle()
                            self.fsmanager.createVacancy(company: self.loginUserID, title: self.title, description: self.description, specialization: self.specialization, qualification: self.qualification, locationType: self.locationType, specifiedLocation: self.specifiedLocation, typeOfEmployment: self.typeOfEmployment, salaryType: self.salaryType, currency: self.currency, salaryLowerBound: self.salaryLowerBound, salaryUpperBound: self.salaryUpperBound, requirements: self.requirements, languages: self.languageDescriptors, observeManager: self.observeManager) { res in
                                switch res {
                                case .success(let success):
                                    print(success)
                                case .failure(let err):
                                    print("Ned to handle error: \(err)")
                                }
                            }
                            print("Upload button pressed")
                        } label: {
                            // MARK: - Deploy Button Label
                            Text("Confirm & Publish")
                                .robotoMono(.bold, 20, color: .white)
                                .frame(maxWidth: UIScreen.main.bounds.width - 64)
                                .frame(height: 45)
                                .background(LinearGradient(colors: [Color("Register2").opacity(0.5), .cyan.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing))
                              
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(LinearGradient(colors: [Color("Register2"), .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                        }
                        Spacer()
                    }.padding()
                   
  
                    
                    Text("")
                        .frame(height: 55)
                }
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("AdditionDarkBackground"))
        }
        .sheet(isPresented: self.$doneUploading, content: {
            VacancyPostPublishingView(onOKButtonPress: {
                self.doneUploading = false
            })
        })
        .onChange(of: self.doneUploading, perform: { newValue in
            if !newValue {
                self.doneUploading = false
                self.rootViewIsActive = false
                
            }
        })
        .hookMBProgressHUD(isPresented: self.$MBProgressHook, progressInPercentages: self.$observeManager.amountPercentage, completion: {
            self.doneUploading = true
            
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("")
            }
        }
    }
    private func getTags(from string: String) -> [String] {
        return string.components(separatedBy: ", ")
    }
}
#if DEBUG

let texttt: String = """
Мы рады объявить об открытии позиции: Middle Front-End Developer.
Мы ищем опытного разработчика, готового решать сложные технические задачи при разработке качественных программных комплексов для уже написанных приложений с использованием современных технологий.
Что нужно уметь:
Уверенное знание JavaScript ES5+
Практический опыт работы с Vue 2, Nuxt.js, Vue CLI, VueX, VueRouter, i18n, Vuelidate, Axios
Опыт работы с REST API
Опыт разработки Расширений для браузеров (Chrome, Firefox, Edge, Opera)
Опыт адаптивной кросс-браузерной и кроссплатформенной разработки HTML5, CSS3, SCSS
Владение инструментом контроля версий Git
Опыт работы с Yarn/Npm, Webpack, Gulp
Опыт работы с [Figma](https://www.google.com)
Английский на уровне чтения технической документации
Будет плюсом:
Firebase
Service Worker
Что мы предлагаем:
Удаленную работу. СБ, ВС — выходные;
Интересные и динамичные проекты;
Возможность для профессионального развития;
Конкурентную заработную плату (по результатам собеседования);
Дружелюбный и молодой коллектив;
Ждем Ваши отклики!
"""

struct VacancyPreview_Previews: PreviewProvider {

    static var previews: some View {
        VacancyPreview(title: "Middle iOS Developer", description: texttt, specialization: .Development, qualification: .Middle, locationType: .specified, specifiedLocation: "Москва", typeOfEmployment: .FullTime, salaryType: .specified, currency: .dollar, salaryLowerBound: "150000", salaryUpperBound: "300000", requirements: "4 YEARS+, Realm, Core Data", languageDescriptors: [.ObjectiveC, .Swift], imageLoader: imageLoader, doneUploading: .constant(false), rootViewIsActive: .constant(true))
    }
}

#endif
