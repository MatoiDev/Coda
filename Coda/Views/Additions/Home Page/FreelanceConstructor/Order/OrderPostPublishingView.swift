//
//  OrderPostPublishingView.swift
//  Coda
//
//  Created by Matoi on 23.02.2023.
//

import SwiftUI

struct OrderPostPublishingView: View {
    
    let onOKButtonPress: () -> ()
    
    @Environment(\.dismiss) var dismiss
    
    init(onOKButtonPress: @escaping () -> Void) {
        self.onOKButtonPress = onOKButtonPress
    }
    
    var body: some View {
        ZStack {
            VStack {
                if Reachability.isConnectedToNetwork() {
                    LottieView(named: "freelanceOrderDone", loop: true)
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
                           
                           
                            .background(Color(red: 113 / 255, green: 140 / 255, blue: 213 / 255))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(.horizontal, 32)
                    }
                } else {
                    LottieView(named: "connectionErrorMan", loop: true)
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width - 32)
                    Text("Whooops...")
                        .padding()
                        .robotoMono(.bold, 45)
                    Text("Connection Lost")
                        .robotoMono(.bold, 15)
                    Spacer()
                    Button {

                        self.dismiss.callAsFunction()
                        
                    } label: {
                        Text("OK")
                            .robotoMono(.bold, 20, color: .black)
                            .frame(maxWidth: .infinity)
                            .padding()
                           
                           
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(.horizontal, 32)
                    }
                }
              
            }
        }.padding()
        
    }
}

struct OrderPostPublishingView_Previews: PreviewProvider {
    static var previews: some View {
        OrderPostPublishingView {
            print("OK")
        }
    }
}
