//
//  ArticleStubView.swift
//  Coda
//
//  Created by Matoi on 22.03.2023.
//

import SwiftUI

struct GrayedFadeAnimated: ViewModifier {
    @State private var colors: [Color] = [.gray, .gray, .gray]
    @Binding var offsetGray: CGFloat
    private let beatLength = 3
    
    func startAnimation() {

        withAnimation(Animation.linear(duration: 0.5)) {
                offsetGray = 500
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(beatLength) * 0.25) {
                offsetGray = -500
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(beatLength)) {
                withAnimation {
                    self.startAnimation()
                }
            }

    }
    
    
    func body(content: Content) -> some View {
        content
            .overlay {
                Color.gray
            }
            .overlay {
                LinearGradient(colors: [Color.clear, Color.init(red: 0.8, green: 0.8, blue: 0.8), Color.clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 100, height: 2000)
                
                    .shadow(color: .white, radius: 50)
                    .rotationEffect(Angle(radians: -.pi / 4))
                    .offset(x: self.offsetGray)
            }.task {
                startAnimation()
            }
    }
}

extension View { func grayedAnimated(_ offset: Binding<CGFloat>) -> some View { modifier(GrayedFadeAnimated(offsetGray: offset)) } }


struct ArticleStubView: View {
    @State private var offsetGray: CGFloat = -500
    var body: some View {
        VStack {
            
            // MARK: - Title
            
            RoundedRectangle(cornerRadius: 10)
                .grayedAnimated(self.$offsetGray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: .infinity)
                .frame(height: 15)
                .padding(.all)
                .foregroundColor(Color.gray)
            
            
            
            // MARK: - Image
            
            RoundedRectangle(cornerRadius: 20)
                .grayedAnimated(self.$offsetGray)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: .infinity)
                .frame(height: 170)
                .padding(.horizontal)
                .padding(.bottom)
                .foregroundColor(Color.gray)
            
            // MARK: - Description
            
            VStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 5)
                    .grayedAnimated(self.$offsetGray)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 5)
                    .grayedAnimated(self.$offsetGray)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 5)
                    .grayedAnimated(self.$offsetGray)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(width: 50, height: 10)
                
            }
            .foregroundColor(Color.gray)
            .padding(.horizontal)
            
            Divider()
            
            // MARK: - Safari Link
            HStack {
                // MARK: - Post rate info
                HStack {
                    // MARK: - Respect Button
                    Button {}
                label: {
                    Image("arrowshape")
                        .resizable()
                        .rotationEffect(Angle(radians: .pi / 2))
                    
                }.buttonStyle(PlainButtonStyle())
                    
                    // MARK: - Post rate
                    RoundedRectangle(cornerRadius: 2)
                        .grayedAnimated(self.$offsetGray)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .frame(width: 15, height: 15)
                    // MARK: - Disrespect Button
                    Button {
                        
                    } label: {
                        Image("arrowshape")
                        
                            .resizable()
                        
                            .rotationEffect(Angle(radians: .pi / -2))
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
                .padding(.leading, 4)
                .fixedSize()
                Spacer()
                Button {
                } label: {
                    HStack {
                        
                        VStack(alignment: .trailing) {
                            RoundedRectangle(cornerRadius: 5)
                                .grayedAnimated(self.$offsetGray)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .frame(width: 45)
                                .frame(height: 10)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .grayedAnimated(self.$offsetGray)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .frame(width: 30)
                                .frame(height: 6)
                        }
                        Image(systemName: "chevron.forward")
                    }
                    
                }.buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            .padding(.top, 1)
            .robotoMono(.semibold, 12, color: .gray)
        }
        .padding(.horizontal, 2)
    }
}

struct ArticleStubView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleStubView()
    }
}
