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
    
    var time: Double
    
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
    
    @State var sortDescriptor: FirestoreSortDescriptor = .newest
    
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
    @State private var openSortDescriptorPicker: Bool = false
    
    
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
    
    var numberOfFiltersApplied: Int {
        
        return [self.sortDescriptor != .newest,
                  self.category != .all,
                  self.subDevCategory != .all,
                  self.subAdminCategory != .all,
                  self.subDesignCategory != .all,
                  self.subTestCategory != .all,
                  self.difficultLevel != .all,
                  self.languages != [.None]].filter({$0}).count
    }
    
    var body: some View {
        VStack {
            
         
                ScrollView(.horizontal, showsIndicators: false) {
                   
             
                        HStack {
                            // MARK: - Filters resetter
                            if numberOfFiltersApplied > 0 {
                                Menu {
                                    Section(header:
                                                Text("\(numberOfFiltersApplied == 1 ? "One" : "\(numberOfFiltersApplied)") filter\(numberOfFiltersApplied == 1 ? "" : "s") applied.").textCase(nil)
                                        .frame(maxWidth: .infinity, alignment: .center)
) {
                                        
                                        Button(LocalizedStringKey("Clear all"), role: .destructive) {
                                            self.sortDescriptor = .newest
                                            self.category = .all
                                            self.subDevCategory = .all
                                            self.subAdminCategory = .all
                                            self.subDesignCategory = .all
                                            self.subTestCategory = .all
                                            self.difficultLevel = .all
                                            self.languages = [.None]
                                            
                                        }
                                    }
                                } label: {
                                    HStack {
                                       Image(systemName: "line.3.horizontal.decrease")
                                            .resizable()
                                            .fixedSize()
                                            .foregroundColor(.secondary)
                                        Image(systemName: "\(numberOfFiltersApplied).circle.fill")
                                            .resizable()
                                            .fixedSize()
                                            .foregroundColor(.primary)
                                    }
                                  
                                }
                                .textCase(nil)
                                .menuStyle(BorderlessButtonMenuStyle())

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
                            // MARK: - Category Header Button
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
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 1, height: 20)
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            Button {
                                
                                self.openSortDescriptorPicker.toggle()

                            } label: {
                                
                                HStack {
                                    switch self.sortDescriptor {
                                    case .newest:
                                        Text("Sort: Newest")
                                    case .oldest:
                                        Text("Sort: Oldest")
                                    case .moreStars:
                                        Text("Sort: More stars")
                                    case .lessStars:
                                        Text("Sort: Less stars")
                                    case .mostCommented:
                                        Text("Sort: Most commented")
                                    case .leastCommented:
                                        Text("Sort: Least commented")
                                    case .mostViewed:
                                        Text("Sort: Most viewed")
                                    case .leastViewed:
                                        Text("Sort: Least viewed")
                                    }
                                    
                                        Image(systemName: "chevron.down")
                                            .resizable()
                                            .fixedSize()
                                            .foregroundColor(self.sortDescriptor == .newest ? .secondary : .black)
                                    
                               
                                }
                            }
                            .robotoMono(.medium, 12, color: self.sortDescriptor == .newest ? .init(red: 0.88, green: 0.88, blue: 0.88) : .black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(self.sortDescriptor == .newest ? Color.init(red: 0.15, green: 0.15, blue: 0.15) : Color("BackgroundColor2"))
                               
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .overlay {
                                    RoundedRectangle(cornerRadius: 25)
                                    .stroke(self.sortDescriptor == .newest ? Color.init(red: 0.88, green: 0.88, blue: 0.88) : .black, style: .init(lineWidth: 1))
                                }
                        }
                 
                    .padding(.top, 1)
                        .padding(.bottom, 1)
                        .padding(.horizontal)
                       
                   
                }.overlay {
                    HStack {
                        LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                            .frame(width: 10)
                        Spacer()
                   
                        LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                            .frame(width: 10)
                        }
                }
   
            
         
            .frame(maxWidth: .infinity)
                .frame(height: 30)
//                .background {
//                    Color(red: 0.11, green: 0.11, blue: 0.11)
//                }
                
            Group {
               
                    List {
                        if ideas.count == 0 {
                           Text("Loading Ideas\nHere have to be a stubs")
                        }
                        ForEach(self.ideas, id: \.self.id) { idea in
                         
                            IdeaCellView(for: idea)
                        }
                    }
                    .overlay(content: {
                        VStack {
                            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                .frame(width: UIScreen.main.bounds.width, height: 20, alignment: .top)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    })
                    .task {
                        fsmanager.loadIdeas(sortBy: sortDescriptor, category: category, subDevCategory: subDevCategory, subAdminCategory: subAdminCategory, subDesignCategory: subDesignCategory, subTestCategory: subTestCategory, difficultLevel: difficultLevel, languages: languages, textStringQuery: self.searchText) { newIdeas in
                            self.ideas = newIdeas
                        }
                    }
                    .refreshable {
                        print(self.sortDescriptor, self.category, self.subDevCategory, self.subAdminCategory, self.subDesignCategory, self.subTestCategory, self.difficultLevel, self.languages)
                        fsmanager.loadIdeas(sortBy: sortDescriptor, category: category, subDevCategory: subDevCategory, subAdminCategory: subAdminCategory, subDesignCategory: subDesignCategory, subTestCategory: subTestCategory, difficultLevel: difficultLevel, languages: languages, textStringQuery: self.searchText) { newIdeas in
                            print(newIdeas)
                            self.ideas = newIdeas
                        }
                    }
                
            }
        Spacer()
        }
        .onChange(of: self.category, perform: { newValue in
            self.subDevCategory = .all
            self.subTestCategory = .all
            self.subDesignCategory = .all
            self.subAdminCategory = .all
        })
        .searchable(text: self.$searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for new ideas...")
        .onChange(of: self.searchText, perform: { _ in
            if self.searchText.isEmpty {
                fsmanager.loadIdeas(sortBy: sortDescriptor, category: category, subDevCategory: subDevCategory, subAdminCategory: subAdminCategory, subDesignCategory: subDesignCategory, subTestCategory: subTestCategory, difficultLevel: difficultLevel, languages: languages, textStringQuery: self.searchText) { newIdeas in
                    print(newIdeas)
                    self.ideas = newIdeas
                }
            }
        })
        .onSubmit(of: .search, {
            print("Make query with string: \(self.searchText)")
            fsmanager.loadIdeas(sortBy: sortDescriptor, category: category, subDevCategory: subDevCategory, subAdminCategory: subAdminCategory, subDesignCategory: subDesignCategory, subTestCategory: subTestCategory, difficultLevel: difficultLevel, languages: languages, textStringQuery: self.searchText) { newIdeas in
                print(newIdeas)
                self.ideas = newIdeas
            }
        })
//            .navigationBarColor(backgroundColor: .init(red: 0.11, green: 0.11, blue: 0.11, alpha: 1), titleColor: UIColor(white: 1, alpha: 1))
            .navigationTitle(LocalizedStringKey("Ideas"))
            .sheet(isPresented: self.$openSortDescriptorPicker, content: {
                SortDescriptorsPickerSheetView(descriptor: self.$sortDescriptor)
            })
            .sheet(isPresented: self.$openLanguagePicker, content: {
                LanguageDescriptorPickerSheet(langDescriptors: self.$languages)
                    .presentationBackground(Color.clear)
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
