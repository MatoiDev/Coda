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
                    HomeViewActionCell(title: "New Project", image: "HomeViewProjectIcon") {active in
                        ProjectConstructorMain()
                    }
                    HomeViewActionCell(title: "New Idea", image: "HomeViewIdeaIcon") {active in
                        Text("Here is Idea constructor")
                    }
                    HomeViewActionCell(title: "Find Team", image: "HomeViewTeamIcon") {active in
                        Text("Here is Team request constructor")
                    }
                    HomeViewActionCell(title: "New Vacation", image: "HomeViewVacationIcon") {active in
                        Text("Here is Vacation constructor")
                    }
                    HomeViewActionCell(title: "Create Resume", image: "HomeViewResumeIcon") {active in
                        Text("Here is Resume constructor")
                    }
                    HomeViewActionCell(title: "Freelance", image: "HomeViewFreelanceIcon") {active in
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
            
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
