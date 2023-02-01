//
//  FreelanceConstructorCrossroadView.swift
//  Coda
//
//  Created by Matoi on 01.02.2023.
//

import SwiftUI

struct FreelanceConstructorCrossroadView: View {
    var body: some View {
        List {
            
            // Order
            NavigationLink {
                OrderConstructor()
            } label: {
                ZStack {
                    Image("FreelanceOrderPreview")
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                        .cornerRadius(25)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    VStack {
                        Text("Order")
                            .robotoMono(.bold, 30)
                            .padding(.horizontal)
                            .padding()
                        
                    }.frame(maxWidth: .infinity, maxHeight: 200, alignment: .topLeading)
                }
               
 
            }.listRowBackground(Color.clear)
            
            
            // Service
            NavigationLink {
                Text("ServiceConstructor")
            } label: {
                        ZStack {
                            Image("FreelanceServicePreview")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            VStack {
                                Text("Service")
                                    .robotoMono(.bold, 30)
                                    .padding(.horizontal)
                                    .padding()
                                
                            }.frame(maxWidth: .infinity, maxHeight: 200, alignment: .topLeading)
                        }
                    
            }.listRowBackground(Color.clear)
            

        }.listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
        .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Freelance")
                        .robotoMono(.semibold, 18)
                }
            }
    }
}


struct FreelanceConstructorCrossroadView_Previews: PreviewProvider {
    static var previews: some View {
        FreelanceConstructorCrossroadView()
    }
}
