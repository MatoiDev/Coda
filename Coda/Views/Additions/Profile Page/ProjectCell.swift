//
//  ProjectCell.swift
//  Coda
//
//  Created by Matoi on 01.11.2022.
//

import SwiftUI

struct ProjectCell: View {
    var project : Project
    init(withProject project: Project) {
        self.project = project
    }
    var colors : [Color] = [Color("BackgroundColor1"), Color("BackgroundColor2"), Color("BackgroundColor3"), Color("Register1"), Color.cyan, Color.purple, Color.yellow, Color.red, Color.green, Color.purple, Color.blue, Color.black, Color.gray]
    var body: some View {
        ZStack {
            ScrollView {}
                .background(.ultraThinMaterial)
                .background(LinearGradient(colors: [colors[Int(arc4random_uniform(UInt32(colors.count)))], colors[Int(arc4random_uniform(UInt32(colors.count)))], colors[Int(arc4random_uniform(UInt32(colors.count)))]], startPoint: .bottomTrailing, endPoint: .topLeading) )
            VStack(alignment: .leading) {
                Image(self.project.image)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .scaledToFit()
                    .cornerRadius(15)
                    .padding()
                    .offset(y: -15)
                    .frame(height: 175)
                VStack {
    
                    Text(self.project.name)
                        .foregroundColor(.primary)
                        .font(.custom("RobotoMono-SemiBold", size: 35))
                    Text(self.project.description)
                        .foregroundColor(.secondary)
                        .font(.custom("RobotoMono-Light", size: 20))
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                        
                }.frame(height: 75)
                    .offset(y: -40)
                    .padding(.horizontal, 10)
                    
                    
                
                
            }.frame(alignment: .top)
        }
        .frame(width: 200, height: 250)
        .cornerRadius(30)
    }
}

struct ProjectCell_Previews: PreviewProvider {
    static var previews: some View {
        ProjectCell(withProject: Project(image: "violet", name: "Violet", description: "The maid for your iPhone"))
    }
}
