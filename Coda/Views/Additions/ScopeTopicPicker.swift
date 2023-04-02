//
//  ScopeTopic.swift
//  Coda
//
//  Created by Matoi on 25.02.2023.
//


import SwiftUI

struct ScopeTopicPickerSheet: View {
    
    @Binding var topic: FreelanceTopic
    @Binding var isPickerAlive: Bool
    
    var body: some View {
        
        NavigationView {
        
                ScrollView {
                    HStack {
                        
                        Button {
                            self.topic = .Administration
                            self.isPickerAlive = false
                        } label: {
                            ZStack(alignment: .topLeading) {
                                Image("FreelanceAdministration")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width / 2 - 16, height: 150)
                                Text("Administration")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.01)
                                    .robotoMono(.semibold, 15, color: .white)
                                    .padding()
                            }
                            
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        
                        Button {
                            self.topic = .Design
                            self.isPickerAlive = false
                            
                        } label: {
                            ZStack(alignment: .topLeading) {
                                Image("FreelanceDesign")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width / 2 - 16, height: 150)
                                Text("Design")
                                    .robotoMono(.semibold, 20, color: .white)
                                    .padding()
                            }
                        }.clipShape(RoundedRectangle(cornerRadius: 25))

                    }.padding(.horizontal)
                    
                    HStack {
                        Button {
                            self.topic = .Development
                            self.isPickerAlive = false
                            
                        } label: {
                            ZStack(alignment: .bottomTrailing) {
                                Image("FreelanceDevelopment")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width / 2 - 16, height: 150)
                                Text("Development")
                                    .robotoMono(.semibold, 20, color: .white)
                                    .padding()
                            }
                        }.clipShape(RoundedRectangle(cornerRadius: 25))
                        
                        Button {
                            self.topic = .Testing
                            self.isPickerAlive = false
                            
                        } label: {
                            ZStack(alignment: .bottomTrailing) {
                                Image("FreelanceTesting")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width / 2 - 16, height: 150)
                                Text("Testing")
                                    .robotoMono(.semibold, 20, color: .white)
                                    .padding()
                            }
                        }.clipShape(RoundedRectangle(cornerRadius: 25))

                    }.padding(.horizontal)
                    
                }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(LocalizedStringKey("Select a Category"))
        }
    }
}


struct ScopeTopicPicker: View {
    
    @Binding var topic: FreelanceTopic
    @Binding var isPickerAlive: Bool
    
    
    
    var body: some View {
        
        VStack(alignment: .center) {
            
            Text("")
                .robotoMono(.bold, 20)
                .frame(height: 50).padding()
          
            ScrollView {
                HStack {
                    
                    Button {
                        self.topic = .Administration
                        self.isPickerAlive = false
                    } label: {
                        ZStack(alignment: .topLeading) {
                            Image("FreelanceAdministration")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 16, height: 150)
                            Text("Administration")
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .robotoMono(.semibold, 15, color: .white)
                                .padding()
                        }
                        
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    
                    Button {
                        self.topic = .Design
                        self.isPickerAlive = false
                        
                    } label: {
                        ZStack(alignment: .topLeading) {
                            Image("FreelanceDesign")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 16, height: 150)
                            Text("Design")
                                .robotoMono(.semibold, 20, color: .white)
                                .padding()
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 25))

                }.padding(.horizontal)
                
                HStack {
                    Button {
                        self.topic = .Development
                        self.isPickerAlive = false
                        
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            Image("FreelanceDevelopment")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 16, height: 150)
                            Text("Development")
                                .robotoMono(.semibold, 20, color: .white)
                                .padding()
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 25))
                    
                    Button {
                        self.topic = .Testing
                        self.isPickerAlive = false
                        
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            Image("FreelanceTesting")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - 16, height: 150)
                            Text("Testing")
                                .robotoMono(.semibold, 20, color: .white)
                                .padding()
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 25))

                }.padding(.horizontal)
                
            }
        }
    }
}

