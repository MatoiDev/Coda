//
//  IdeasView.swift
//  Coda
//
//  Created by Matoi on 26.01.2023.
//

import SwiftUI




struct Idea: CloudFirestoreItemDelegate {
    
    var id: String
    var author: String
    
    var title: String
    var text: String
    var category: String
    var subcategory: String
    var difficultyLevel: String
    var skills: String
    var languages: Array<String>
    var images: Array<String>
    var files: Array<String>
    //var timeInSeconds: Double
    
    var comments: Array<String>
    var stars: Array<String>
    var responses: Array<String>
    var views: Array<String>
    var saves: Array<String>
    
    var dateOfPublish: String
    
}


struct NavigationViewHeaderButton: View {
    
    let text: String
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(text)
                Image(systemName: "chevron.down")
                    .resizable()
                    .fixedSize()
                    .foregroundColor(.secondary)
            }
          
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.init(red: 0.15, green: 0.15, blue: 0.15))
       
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.init(red: 0.88, green: 0.88, blue: 0.88), style: .init(lineWidth: 1))
        }
        .robotoMono(.medium, 12, color: .init(red: 0.88, green: 0.88, blue: 0.88))
    }
}

struct IdeasView: View {
    private let fsmanager: FSManager = FSManager()
    
    @State var ideas: Array<Idea> = Array<Idea>()
    
    @State var searchText: String = ""
    
    @State var sortDescriptor: FirestoreSortDescriptor = .time
    
    @State var category: FreelanceTopic = FreelanceTopic.all
    
    @State var subDevCategory: FreelanceSubTopic.FreelanceDevelopingSubTopic = FreelanceSubTopic.FreelanceDevelopingSubTopic.all
    @State var subAdminCategory: FreelanceSubTopic.FreelanceAdministrationSubTropic = FreelanceSubTopic.FreelanceAdministrationSubTropic.all
    @State var subDesignCategory: FreelanceSubTopic.FreelanceDesignSubTopic = FreelanceSubTopic.FreelanceDesignSubTopic.all
    @State var subTestCategory: FreelanceSubTopic.FreelanceTestingSubTopic = FreelanceSubTopic.FreelanceTestingSubTopic.all
    
    @State var difficultLevel: IdeaDifficultyLevel = IdeaDifficultyLevel.all
    
    @State var languages: Array<LangDescriptor> = [LangDescriptor.None]
    
    @State private var openCategoryPicker: Bool = false
    @State private var openSubcategoryPicker: Bool = false
    @State private var openLanguagePicker: Bool = false
    
//    @State var languages: Array<LangDescriptor.RawValue> = [LangDescriptor.Logos.rawValue]
    
    var subcategoryLabel: String {
        switch self.category {
        case .all:
            return "Subcategory"
        case .Testing:
            return self.subTestCategory == .all ? "Subcategory" : self.subTestCategory.rawValue
        case .Design:
            return self.subDesignCategory == .all ? "Subcategory" : self.subDesignCategory.rawValue
        case .Administration:
            return self.subAdminCategory == .all ? "Subcategory" : self.subAdminCategory.rawValue
        case .Development:
            return self.subDevCategory == .all ? "Subcategory" : self.subDevCategory.rawValue
        }
    }
    var subcategoryChosen: Bool {
        switch self.category {
        case .all:
            return false
        case .Testing:
            return self.subTestCategory == .all
        case .Design:
            return self.subDesignCategory == .all
        case .Administration:
            return self.subAdminCategory == .all
        case .Development:
            return self.subDevCategory == .all
        }
    }
    
    var body: some View {
    
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                // MARK: - Category Header Button
                HStack {
                    Button {
                        self.openCategoryPicker.toggle()
                    } label: {
                        HStack {
                            Text(self.category == .all ? "Category" : self.category.rawValue)
                            Image(systemName: "chevron.down")
                                .resizable()
                                .fixedSize()
                                .foregroundColor(self.category == .all ? .secondary : .black)
                        }
                      
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(self.category == .all ? Color.init(red: 0.15, green: 0.15, blue: 0.15) : Color("BackgroundColor2"))
                   
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .overlay {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(self.category == .all ? Color.init(red: 0.88, green: 0.88, blue: 0.88) : .black, style: .init(lineWidth: 1))
                    }
                    .robotoMono(.medium, 12, color: self.category == .all ? .init(red: 0.88, green: 0.88, blue: 0.88) : .black)
                    
                    // MARK: - Subcategory Header Button
                    if self.category != .all {
                        Button {
                            self.openSubcategoryPicker.toggle()
                        } label: {
                            HStack {
                                switch self.category {
                                case .all:
                                    Text("Subcategory")
                                case .Development:
                                    Text(self.subDevCategory == .all ? "Subcategory" : self.subDevCategory.rawValue)
                                case .Administration:
                                    Text(self.subAdminCategory == .all ? "Subcategory" : self.subAdminCategory.rawValue)
                                case .Design:
                                    Text(self.subDesignCategory == .all ? "Subcategory" : self.subDesignCategory.rawValue)
                                case .Testing:
                                    Text(self.subTestCategory == .all ? "Subcategory" : self.subTestCategory.rawValue)
                                }
    
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .fixedSize()
                                    .foregroundColor(subcategoryChosen ? .secondary : .black)
                            }
                          
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(subcategoryChosen ? Color.init(red: 0.15, green: 0.15, blue: 0.15) : Color("BackgroundColor2"))
                       
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay {
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(subcategoryChosen ? Color.init(red: 0.88, green: 0.88, blue: 0.88) : .black, style: .init(lineWidth: 1))
                        }
                        .robotoMono(.medium, 12, color: subcategoryChosen ? .init(red: 0.88, green: 0.88, blue: 0.88) : .black)
                    }
                    
                    // MARK: - Language Picker Header Button
                    Button {
                        self.openLanguagePicker.toggle()
                    } label: {
                        HStack {
                            Text(self.languages == [.None] || self.languages == [] ? "Languages" : self.languages.count == 1 ? self.languages[0].rawValue : "\(self.languages[0].rawValue) and \(self.languages.count - 1) more")
                            Image(systemName: "chevron.down")
                                .resizable()
                                .fixedSize()
                                .foregroundColor(self.languages == [.None] || self.languages == [] ? .secondary : .black)
                        }
                      
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(self.languages == [.None] || self.languages == [] ? Color.init(red: 0.15, green: 0.15, blue: 0.15) : Color("BackgroundColor2"))
                   
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .overlay {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(self.languages == [.None] || self.languages == [] ? Color.init(red: 0.88, green: 0.88, blue: 0.88) : .black, style: .init(lineWidth: 1))
                    }
                    .robotoMono(.medium, 12, color: self.languages == [.None] || self.languages == [] ? .init(red: 0.88, green: 0.88, blue: 0.88) : .black)
                    
                    
                    // MARK: - Qualification Picker Header Button
                    Menu {
                        Button {
                            self.difficultLevel = .all
                        } label: {
                            HStack {
                                if self.difficultLevel == .all {
                                    Image(systemName: "checkmark")
                                }
                                Text(IdeaDifficultyLevel.all.rawValue)
                            }
                           
                        }
                        Button {
                            self.difficultLevel = .newbie
                        } label: {
                            HStack {
                                if self.difficultLevel == .newbie {
                                    Image(systemName: "checkmark")
                                }
                                Text(IdeaDifficultyLevel.newbie.rawValue)
                            }
                           
                        }
                        
                        Button {
                            self.difficultLevel = .intern
                        } label: {
                            HStack {
                                if self.difficultLevel == .intern {
                                    Image(systemName: "checkmark")
                                }
                                Text(IdeaDifficultyLevel.intern.rawValue)
                            }
                           
                        }
                        
                        Button {
                            self.difficultLevel = .junior
                        } label: {
                            HStack {
                                if self.difficultLevel == .junior {
                                    Image(systemName: "checkmark")
                                }
                                Text(IdeaDifficultyLevel.junior.rawValue)
                            }
                           
                        }
                        
                        Button {
                            self.difficultLevel = .middle
                        } label: {
                            HStack {
                                if self.difficultLevel == .middle {
                                    Image(systemName: "checkmark")
                                }
                                Text(IdeaDifficultyLevel.middle.rawValue)
                            }
                           
                        }
                        
                        Button {
                            self.difficultLevel = .senior
                        } label: {
                            HStack {
                                if self.difficultLevel == .senior {
                                    Image(systemName: "checkmark")
                                }
                                Text(IdeaDifficultyLevel.senior.rawValue)
                            }
                           
                        }
                        
                        Button {
                            self.difficultLevel = .lead
                        } label: {
                            HStack {
                                if self.difficultLevel == .lead {
                                    Image(systemName: "checkmark")
                                }
                                Text(IdeaDifficultyLevel.lead.rawValue)
                            }
                           
                        }

                    } label: {
                        
                        HStack {
                            
                                Text(self.difficultLevel == .all ? "Сompetence" : self.difficultLevel.rawValue)
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .fixedSize()
                                    .foregroundColor(self.difficultLevel == .all ? .secondary : .black)
                            
                       
                        }
                    }
                    .robotoMono(.medium, 12, color: self.difficultLevel == .all ? .init(red: 0.88, green: 0.88, blue: 0.88) : .black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(self.difficultLevel == .all ? Color.init(red: 0.15, green: 0.15, blue: 0.15) : Color("BackgroundColor2"))
                       
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .overlay {
                            RoundedRectangle(cornerRadius: 25)
                            .stroke(self.difficultLevel == .all ? Color.init(red: 0.88, green: 0.88, blue: 0.88) : .black, style: .init(lineWidth: 1))
                        }
                   
//
//                    NavigationViewHeaderButton(text: "Сompetence") {
//                        self.openCategoryPicker.toggle()
//                    }
                    
                    
                    
                }
                .padding(.top, 1)
                    .padding(.bottom, 16)
                    .padding(.horizontal)
                   
               
            }
         
            .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background {
                    Color(red: 0.11, green: 0.11, blue: 0.11)
                }
                Divider()
            Group {
                if ideas.count == 0 {
                   Text("Loading Ideas\nHere have to be a stubs")
                        .task {
                            fsmanager.loadIdeas(sortBy: sortDescriptor, category: category, subDevCategory: subDevCategory, subAdminCategory: subAdminCategory, subDesignCategory: subDesignCategory, subTestCategory: subTestCategory, difficultLevel: difficultLevel, languages: languages) { newIdeas in
                                self.ideas = newIdeas
                            }
                        }
                } else {
                    List {
                        ForEach(self.ideas, id: \.self.id) { idea in
                            IdeaCellView(for: idea)
                        }
                    }.refreshable {
                        print(self.sortDescriptor, self.category, self.subDevCategory, self.subAdminCategory, self.subDesignCategory, self.subTestCategory, self.difficultLevel, self.languages)
                        fsmanager.loadIdeas(sortBy: self.sortDescriptor, category: self.category, subDevCategory: subDevCategory, subAdminCategory: subAdminCategory, subDesignCategory: subDesignCategory, subTestCategory: subTestCategory, difficultLevel: difficultLevel, languages: languages) { newIdeas in
                            print(newIdeas)
                            self.ideas = newIdeas
                        }
                    }
                }
            }
        Spacer()
        }    .searchable(text: self.$searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for new ideas...")
            .navigationBarColor(backgroundColor: .init(red: 0.11, green: 0.11, blue: 0.11, alpha: 1), titleColor: UIColor(white: 1, alpha: 1))
            .navigationTitle(LocalizedStringKey("Ideas"))
            .sheet(isPresented: self.$openLanguagePicker, content: {
                LanguageDescriptorPickerSheet(langDescriptors: self.$languages)
            })
            .sheet(isPresented: self.$openSubcategoryPicker, content: {
                SubcategoryPickerSheet(self.category, setTo: self.$category, devSubtopic: self.$subDevCategory, adminSubtopic: self.$subAdminCategory, designSubtopic: self.$subDesignCategory, testSubtopic: self.$subTestCategory, killOn: self.$openSubcategoryPicker)
            })
            .sheet(isPresented: self.$openCategoryPicker) {
                
                ScopeTopicPickerSheet(topic: self.$category, isPickerAlive: self.$openCategoryPicker)
                }
    }
        
    }


struct IdeasView_Previews: PreviewProvider {
    static var previews: some View {
        IdeasView()
    }
}
