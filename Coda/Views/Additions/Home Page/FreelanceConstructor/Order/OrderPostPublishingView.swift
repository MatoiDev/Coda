//
//  OrderPostPublishingView.swift
//  Coda
//
//  Created by Matoi on 23.02.2023.
//

import SwiftUI

struct OrderPostPublishingView: View {
    
    let onOKButtonPress: () -> ()
    
    init(onOKButtonPress: @escaping () -> Void) {
        self.onOKButtonPress = onOKButtonPress
    }
    
    var body: some View {
        ZStack {
            VStack {
                LottieView(named: "engagedDeveloper", loop: true)
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 32)
                
                Text("The order was successfully published.")
                    .robotoMono(.bold, 15)
                Spacer()
                Button {
                    self.onOKButtonPress()
                } label: {
                    Text("OK")
                        .robotoMono(.bold, 20, color: .black)
                        .frame(maxWidth: .infinity)
                        .padding()
                       
                       
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .padding(.horizontal, 32)
                }
            }
        }.padding()
        
    }
}

//struct OrderPostPublishingView_Previews: PreviewProvider {
//    static var previews: some View {
//        OrderPostPublishingView()
//    }
//}
