//
//  LanguageDescriptorPicker.swift
//  Coda
//
//  Created by Matoi on 14.02.2023.
//

import SwiftUI

fileprivate enum LanguageTitle: String { // To avoid hard-coding
    case topLanguages = "Top Languages",
         searchResults = "Search Results"
}

struct LanguageDescriptorPickerSheet: View {
    
    @Environment(\.dismiss) var dissmiss
    @Binding var langDescriptors: [LangDescriptor]
    
    init(langDescriptors: Binding<Array<LangDescriptor>>) {
        self._langDescriptors = langDescriptors
        
        UITableView.appearance().backgroundColor = UIColor.black
    }
    
    @State var descriptorsToSet: Set<LangDescriptor> = Set<LangDescriptor>()
    @State private var searchableText: String = ""
    @State var languages: [LangDescriptor] = [.Java, .Python, .CPP, .C, .JavaScript, .Kotlin, .TypeScript, .Dart, .Go, .Ruby, .Rust, .Swift, .PHP, .CSharp, .MATLAB, .Perl, .Scala]
    @State private var languagesTitle: String = "Top Languages"
    
    let topLanguages: [LangDescriptor] = [.Java, .Python, .CPP, .C, .JavaScript, .Kotlin, .TypeScript, .Dart, .Go, .Ruby, .Rust, .Swift, .PHP, .CSharp, .MATLAB, .Perl, .Scala]
    
    var body: some View {
        
        NavigationView {
           
            List {
                
                if let descriptors = Array(self.descriptorsToSet),
                   !descriptors.isEmpty,
                   descriptors != [LangDescriptor.defaultValue] {
                    Section {
                        ForEach(0..<(descriptors.count), id: \.self) { langIndex in
                            let lang = descriptors[langIndex]
                            Button {
                                self.descriptorsToSet.remove(lang)
                            } label: {
                                Text(lang.rawValue)
                                    .robotoMono(.semibold, 15, color: .black)
                            }.listRowBackground(Color.indigo)
                        }
                    } header: {
                        HStack {
                            Text(LocalizedStringKey("Selected Languages"))
                                .robotoMono(.semibold, 20)
                            Spacer()
                        }
                        
                    }.textCase(nil)
                }
                
                Section {
                    
                    ForEach(0..<(self.languages.count == 0 ? 1 : 15), id: \.self) { langIndex in
                        if let lang = self.languages[safe: langIndex] {
                            Button {
                                print("here")
                                if !self.descriptorsToSet.contains(lang) {
                                    print("Now contains")
                                    self.descriptorsToSet.insert(lang)
                                    self.descriptorsToSet.remove(LangDescriptor.defaultValue)
                                } else {
                                    print("Now doesnt contain")
                                    self.descriptorsToSet.remove(lang)
                                    if self.descriptorsToSet.count == 0 {
                                        self.descriptorsToSet.insert(LangDescriptor.defaultValue)
                                    }
                                }
                                

                            } label: {
                                Text(lang.rawValue)
                                    .robotoMono(.semibold, 15, color: self.descriptorsToSet.contains(lang) ? Color.black : Color.white)
                            }.listRowBackground(self.descriptorsToSet.contains(lang) ? Color.green : Color(red: 0.17, green: 0.17, blue: 0.18))
                            
                        }
                        if self.languages.count == 0 {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .fixedSize()
                                    .padding(.horizontal)
                                Text(LocalizedStringKey("Nothing was found for this request..."))
                                
                            }
                            .lineLimit(1)
                            .minimumScaleFactor(0.001)
                            .robotoMono(.semibold, 15, color: .blue)
                            .listRowBackground(Color.clear)
                            
                        }
                       
                    }
                } header: {
                    HStack {
                        Text(LocalizedStringKey(self.languagesTitle))
                            .robotoMono(.semibold, 20)
                        Spacer()
                    }
                    
                }.textCase(nil)
                Section {
                    Text("")
                }
                    .listRowBackground(Color.clear)
            }
            .background(Color.black)
          
            .overlay(content: {
                ZStack {
                    LinearGradient(colors: [.init(red: 0.11, green: 0.11, blue: 0.11), .clear], startPoint: .top, endPoint: .bottom)
                        .frame(width: UIScreen.main.bounds.width, height: 10)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            })
            
            .navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
//            .background(Color.init(red: 0.33, green: 0.33, blue: 0.33))
            .background(Color.black)
            .onAppear {
                self.descriptorsToSet = Set(self.langDescriptors)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(LocalizedStringKey("Choose language"))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.langDescriptors = Array(descriptorsToSet) == [] ? [LangDescriptor.None] : Array(descriptorsToSet)
                            self.dissmiss.callAsFunction()
                        } label: {
                            Text("Done")
                                .robotoMono(.bold, 16, color: Color("Register2"))
                        }

                }
            }
            .searchable(text: self.$searchableText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Language")
            .onChange(of: self.searchableText) { text in
                
                if !text.isEmpty {
                    self.languages = LangDescriptor.allLanguages.filter { $0.rawValue.lowercased().contains("\(text)".lowercased())}
                    self.languagesTitle = LanguageTitle.searchResults.rawValue
                } else {
                    self.languages = self.topLanguages
                    self.languagesTitle = LanguageTitle.topLanguages.rawValue
                }
                
            }
//            .navigationBarColor(backgroundColor: UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1), titleColor: .white)
        }.background(Color.black)

    }
}

struct LanguageDescriptorPicker: View {

    @Environment(\.dismiss) var dissmiss
    @Binding var langDescriptors: [LangDescriptor]
    
    @State var descriptorsToSet: Set<LangDescriptor> = Set<LangDescriptor>()
    @State private var searchableText: String = ""
    @State var languages: [LangDescriptor] = [.Java, .Python, .CPP, .C, .JavaScript, .Kotlin, .TypeScript, .Dart, .Go, .Ruby, .Rust, .Swift, .PHP, .CSharp, .MATLAB, .Perl, .Scala]
    @State private var languagesTitle: String = "Top Languages"
    
    let topLanguages: [LangDescriptor] = [.Java, .Python, .CPP, .C, .JavaScript, .Kotlin, .TypeScript, .Dart, .Go, .Ruby, .Rust, .Swift, .PHP, .CSharp, .MATLAB, .Perl, .Scala]
    
    var body: some View {
        List {
            
            if let descriptors = Array(self.descriptorsToSet),
               !descriptors.isEmpty,
               descriptors != [LangDescriptor.defaultValue] {
                Section {
                    ForEach(0..<(descriptors.count), id: \.self) { langIndex in
                        let lang = descriptors[langIndex]
                        Button {
                            self.descriptorsToSet.remove(lang)
                        } label: {
                            Text(lang.rawValue)
                                .robotoMono(.semibold, 15, color: .black)
                        }.listRowBackground(Color.indigo)
                    }
                } header: {
                    HStack {
                        Text(LocalizedStringKey("Selected Languages"))
                            .robotoMono(.semibold, 20)
                        Spacer()
                    }
                    
                }.textCase(nil)
            }
            
            Section {
                
                ForEach(0..<(self.languages.count == 0 ? 1 : 15), id: \.self) { langIndex in
                    if let lang = self.languages[safe: langIndex] {
                        Button {
                            print("here")
                            if !self.descriptorsToSet.contains(lang) {
                                print("Now contains")
                                self.descriptorsToSet.insert(lang)
                                self.descriptorsToSet.remove(LangDescriptor.defaultValue)
                            } else {
                                print("Now doesnt contain")
                                self.descriptorsToSet.remove(lang)
                                if self.descriptorsToSet.count == 0 {
                                    self.descriptorsToSet.insert(LangDescriptor.defaultValue)
                                }
                            }
                            

                        } label: {
                            Text(lang.rawValue)
                                .robotoMono(.semibold, 15, color: self.descriptorsToSet.contains(lang) ? Color.black : Color.white)
                        }.listRowBackground(self.descriptorsToSet.contains(lang) ? Color.green : Color(red: 0.11, green: 0.11, blue: 0.12))
                        
                    }
                    if self.languages.count == 0 {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .fixedSize()
                                .padding(.horizontal)
                            Text(LocalizedStringKey("Nothing was found for this request..."))
                            
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.001)
                        .robotoMono(.semibold, 15, color: .blue)
                        .listRowBackground(Color.clear)
                        
                    }
                   
                }
            } header: {
                HStack {
                    Text(LocalizedStringKey(self.languagesTitle))
                        .robotoMono(.semibold, 20)
                    Spacer()
                }
                
            }.textCase(nil)
            Section {
                Text("")
            }
                .listRowBackground(Color.clear)
        }
        .onAppear {
            self.descriptorsToSet = Set(self.langDescriptors)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(LocalizedStringKey("Choose language"))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    self.langDescriptors = Array(descriptorsToSet) == [] ? [LangDescriptor.None] : Array(descriptorsToSet)
                    self.dissmiss.callAsFunction()
                } label: {
                    Text("Done")
                        .robotoMono(.bold, 16, color: Color("Register2"))
                }

            }
        }
        .searchable(text: self.$searchableText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Language")
    
        .onChange(of: self.searchableText) { text in
            
            if !text.isEmpty {
                self.languages = LangDescriptor.allLanguages.filter { $0.rawValue.lowercased().contains("\(text)".lowercased())}
                self.languagesTitle = LanguageTitle.searchResults.rawValue
            } else {
                self.languages = self.topLanguages
                self.languagesTitle = LanguageTitle.topLanguages.rawValue
            }
            
        }
    }
}



