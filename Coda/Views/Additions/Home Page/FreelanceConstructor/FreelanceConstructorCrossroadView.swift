//
//  FreelanceConstructorCrossroadView.swift
//  Coda
//
//  Created by Matoi on 01.02.2023.
//

import SwiftUI

struct FreelanceConstructorCrossroadView: View {
    
    // Использование этого колхозного способа позволяет избавиться от chevron в NavigationLink
    @State private var linkToOrder: Bool = false
    @State private var linkToService: Bool = false
    
    @Binding var rootViewIsActive: Bool
    
    var body: some View {
        List {
            
            // Service
            Button {
                self.linkToService.toggle()
            } label: {
                        ZStack {
                            Image("FreelanceServicePreview")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width - 64, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            VStack {
                                Text("Service")
                                    .robotoMono(.bold, 30, color: .black)
                                    .padding(.horizontal)
                                    .padding()
                                
                            }.frame(maxWidth: .infinity, maxHeight: 200, alignment: .topTrailing)
                        }
                    
            }.overlay(
                NavigationLink(
                    isActive: self.$linkToService,
                    destination: { ServiceConstructor(rootViewIsActive: self.$rootViewIsActive) },
                    label: { EmptyView() }
                )
                .isDetailLink(false)
                .opacity(0)
                
            )
            .listRowBackground(Color.clear)
            
            // Order
            Button {
                self.linkToOrder.toggle()
            } label: {
                ZStack {
                    Image("FreelanceOrderPreview")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width - 64, height: 200)
                        .cornerRadius(25)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    VStack {
                        Text("Order")
                            .robotoMono(.bold, 30, color: .black)
                            .padding(.horizontal)
                            .padding()
                        
                    }.frame(maxWidth: .infinity, maxHeight: 200, alignment: .topLeading)
                }
               
 
            }
            .overlay(
                NavigationLink(
                    isActive: self.$linkToOrder,
                    destination: { OrderConstructor(rootViewIsActive: self.$rootViewIsActive) },
                    label: { EmptyView() }
                )
                .isDetailLink(false)
                .opacity(0)
            )
            .listRowBackground(Color.clear)
    
        }
        .onAppear {
            UITableView.appearance().separatorColor = UIColor.clear
        }
        .listRowSeparator(.hidden)
        .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Freelance")
                        .robotoMono(.semibold, 18)
                }
            }
    }
}


struct FreelanceConstructorCrossroadView_Previews: PreviewProvider {
    static var previews: some View {
        FreelanceConstructorCrossroadView(rootViewIsActive: .constant(true))
    }
}
