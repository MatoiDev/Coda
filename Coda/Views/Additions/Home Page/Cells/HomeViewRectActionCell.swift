//
//  HomeViewRectActionCell.swift
//  Coda
//
//  Created by Matoi on 29.03.2023.
//

import SwiftUI

struct HomeViewRectActionCell<Content: View>: View {
    
    @State var isActive: Bool = false
    
    private let text: String
    private let animatedIconName: String
    private let iconWidthSize: CGFloat
    private let iconHeightSize: CGFloat
    
    @ViewBuilder private let destination: (_ active: Binding<Bool>) ->  Content
   
    init(withText text: String, icon: String, iconWidthSize: CGFloat=45, iconHeightSize: CGFloat=45, @ViewBuilder destination: @escaping (_ active: Binding<Bool>) -> Content) {
        self.text = text
        self.animatedIconName = icon
        self.iconWidthSize = iconWidthSize
        self.iconHeightSize = iconHeightSize
        self.destination = destination
    }
    
    var body: some View {
        
        
        Button {
            self.isActive.toggle()
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    LottieView(named: self.animatedIconName, loop: true)
                        .frame(width: self.iconWidthSize, height: self.iconHeightSize)
                    Spacer()
                }
                Text(LocalizedStringKey(text))
                    .robotoMono(.semibold, 15, color: .white)
            
                
            }.padding(.leading).padding(.bottom).padding(.top, 8)
                .background(Color(red: 0.11, green: 0.11, blue: 0.11))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .frame(maxWidth: UIScreen.main.bounds.width / 2, maxHeight: UIScreen.main.bounds.height / 10)

                
        }.overlay(
            NavigationLink(
                isActive: self.$isActive,
                destination: { destination($isActive) },
                label: { EmptyView() }
            )
            .isDetailLink(false)
            .opacity(0)
            
        )
        .listRowBackground(Color.clear)
        
    }
}

//struct HomeViewRectActionCell_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeViewRectActionCell<<#Content: View#>>(withText: "Trends", icon: "laptop", iconWidthSize: 45, iconHeightSize: 45, destination: .constant(true))
//    }
//}
