//
//  HomeView.swift
//  Coda
//
//  Created by Matoi on 30.10.2022.
//

import SwiftUI


struct UppercasedListHeader: ViewModifier {
    
    let tintColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.custom("RobotoMono-Bold", size: 17))
            .foregroundColor(self.tintColor)
    }
    
}

struct LowercasedListHeader: ViewModifier {
    
    let tintColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.custom("RobotoMono-SemiBold", size: 11))
            .foregroundColor(self.tintColor)
    }
}

extension View {
    func uppercasedListHeader(tint: Color = .white) -> some View {
        modifier(UppercasedListHeader(tintColor: tint))
    }
    
    func lowercasedListHeader(tint: Color = .white) -> some View {
        modifier(LowercasedListHeader(tintColor: tint))
    }
}

struct HomeView: View {
    
    @State private var searchResult: String = ""
    var body: some View {
        SearchNavigation(text: self.$searchResult,
                         search: { print("Search") },
                         cancel: { print("Cancel") },
                         content: {
            List {
                Section {
                    HomeViewActionCell(title: "New Project", image: "CPL42") {
                        Text("Create new project view")
                    }
                    HomeViewActionCell(title: "New Idea", image: "CPL43") {
                        Text("Create new Idea view")
                    }
                    HomeViewActionCell(title: "New Announcement", image: "CPL44") {
                        Text("Create new Announcement view")
                    }
                    HomeViewActionCell(title: "New Vacation", image: "CPL45") {
                        Text("Create new Vacation view")
                    }
                    HomeViewActionCell(title: "New Freelance order", image: "CPL46") {
                        Text("Create new Freelance order view")
                    }
                } header: {
                    Text("New Discussion")
                        .uppercasedListHeader()
                        .padding(.bottom, 8)
                }
                .textCase(nil)
                .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                
                Section {
                    HomeViewActionCell(title: "New Project", image: "CPL42") {
                        Text("Create new project view")
                    }
                    HomeViewActionCell(title: "New Idea", image: "CPL43") {
                        Text("Create new Idea view")
                    }
                    HomeViewActionCell(title: "New Announcement", image: "CPL44") {
                        Text("Create new Announcement view")
                    }
                    HomeViewActionCell(title: "New Vacation", image: "CPL45") {
                        Text("Create new Vacation view")
                    }
                    HomeViewActionCell(title: "New Freelance order", image: "CPL46") {
                        Text("Create new Freelance order view")
                    }
                } header: {
                    HStack {
                        
                        Text("New Discussion")
                        Image(systemName: "plus.circle")
                        
                    }.uppercasedListHeader()
                        .padding(.bottom, 8)
                    
                }
                .textCase(nil)
                .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                
                Section {
                    HomeViewActionCell(title: "New Project", image: "CPL42") {
                        Text("Create new project view")
                    }
                    HomeViewActionCell(title: "New Idea", image: "CPL43") {
                        Text("Create new Idea view")
                    }
                    HomeViewActionCell(title: "New Announcement", image: "CPL44") {
                        Text("Create new Announcement view")
                    }
                    HomeViewActionCell(title: "New Vacation", image: "CPL45") {
                        Text("Create new Vacation view")
                    }
                    HomeViewActionCell(title: "New Freelance order", image: "CPL46") {
                        Text("Create new Freelance order view")
                    }
                } header: {
                    HStack {
                        
                        Image(systemName: "plus.circle")
                        Text("New Discussion")

                    }.uppercasedListHeader()
                        .padding(.bottom, 8)
                }
                .textCase(nil)
                .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Text("")
//                    .padding()
                    .listRowBackground(Color.clear)
            }.navigationBarTitle("Home")
        }).edgesIgnoringSafeArea(.top)
            
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
