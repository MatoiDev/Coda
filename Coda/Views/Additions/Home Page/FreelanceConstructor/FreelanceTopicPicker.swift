//
//  FreelanceTopicPicker.swift
//  Coda
//
//  Created by Matoi on 09.02.2023.
//

import SwiftUI


struct FreelanceTopicPicker: View {
    
    @Binding var topic: FreelanceTopic
    
    @Binding var isPickerAlive: Bool
    
    @Binding var devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic
    @Binding var adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic
    @Binding var designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic
    @Binding var testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic
    
    @State private var showSubTopicPicker: Bool = false
    
    var body: some View {
        ScrollView {
            HStack {
                
                NavigationLink {
                    FreelanceSubTopicPicker(.Administration, setTo: self.$topic, devSubtopic: self.$devSubtopic, adminSubtopic: self.$adminSubtopic, designSubtopic: self.$designSubtopic, testSubtopic: self.$testSubtopic, killOn: self.$isPickerAlive)
                    
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
                    
                }.isDetailLink(false)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                
                NavigationLink {
                    FreelanceSubTopicPicker(.Design, setTo: self.$topic, devSubtopic: self.$devSubtopic, adminSubtopic: self.$adminSubtopic, designSubtopic: self.$designSubtopic, testSubtopic: self.$testSubtopic, killOn: self.$isPickerAlive)
                    
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
                NavigationLink {
                    FreelanceSubTopicPicker(.Development, setTo: self.$topic, devSubtopic: self.$devSubtopic, adminSubtopic: self.$adminSubtopic, designSubtopic: self.$designSubtopic, testSubtopic: self.$testSubtopic, killOn: self.$isPickerAlive)
                    
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
                
                NavigationLink {
                    FreelanceSubTopicPicker(.Testing, setTo: self.$topic, devSubtopic: self.$devSubtopic, adminSubtopic: self.$adminSubtopic, designSubtopic: self.$designSubtopic, testSubtopic: self.$testSubtopic, killOn: self.$isPickerAlive)
                    
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

//struct FreelanceTopicPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        FreelanceTopicPicker()
//    }
//}
