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
            .robotoMono(.bold, 17, color: self.tintColor)
    }
    
}

struct LowercasedListHeader: ViewModifier {
    
    let tintColor: Color
    
    func body(content: Content) -> some View {
        content
            .robotoMono(.semibold, 11, color: self.tintColor)
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
                    VStack(alignment: .center, spacing: 8) {
                        HStack(alignment: .center, spacing: 12) {
                            HomeViewRectActionCell(withText: "In Trend", icon: "fireOutline") { active in
                                TrendsView()
                            }
                            
                            HomeViewRectActionCell(withText: "Projects", icon: "boxOutline") { active in
//                                ProjectsView()
                            }
                            
                        }
                        .padding(.bottom)
                        HStack(alignment: .center, spacing: 12) {
                            HomeViewRectActionCell(withText: "Career", icon: "computerOut") { active in
                                JobView()
                            }
                            
                            HomeViewRectActionCell(withText: "Ideas", icon: "bulbOutline") { active in
                                IdeasView()
                            }
                           
                        }
                    }

                   
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
                    .buttonStyle(.plain)
                Section {
                    HomeViewActionCell(title: "New Project", image: "HomeViewProjectIcon") { active in
                        ProjectConstructorMain(rootViewIsActive: active)
                    }
                    HomeViewActionCell(title: "New Idea", image: "HomeViewIdeaIcon") { active in
                        IdeaConstructorMain(rootViewIsActive: active)
                    }
                    HomeViewActionCell(title: "Find Team", image: "HomeViewTeamIcon") { active in
                        FindTeamConstructor(rootViewIsActive: active)
                    }
                    HomeViewActionCell(title: "New Vacancy", image: "HomeViewVacancyIcon") { active in
                        VacancyConstructorMain(rootViewIsActive: active)
                    }
                    HomeViewActionCell(title: "Create Resume", image: "HomeViewResumeIcon") { active in
                        Text("Here is Resume constructor")
                    }
                    HomeViewActionCell(title: "Freelance", image: "HomeViewFreelanceIcon") { active in
                        FreelanceConstructorCrossroadView(rootViewIsActive: active)
                    }
                } header: {
                    Text("New Discussion")
                        .uppercasedListHeader()
                        .padding(.bottom, 8)
                }
                .textCase(nil)
                .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                
                Text("")
                
                    .listRowBackground(Color.clear)
            }.navigationBarTitle("Home")
        }, accentColor: UIColor(Color.cyan)).edgesIgnoringSafeArea(.top)
            .background(Color.black)
            .ignoresSafeArea(edges: .bottom)
            
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
