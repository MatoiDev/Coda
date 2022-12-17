//
//  ProjectCell.swift
//  Coda
//
//  Created by Matoi on 01.11.2022.
//

import SwiftUI

struct ProjectCell: View, Equatable {
    static func == (lhs: ProjectCell, rhs: ProjectCell) -> Bool {
       true
    }
    
    
    @ObservedObject var project : UOProject
    @State var urlString : String?
    @ObservedObject var urlImageModel: CachedImageModel = CachedImageModel(urlString: nil)

    var projectID: String
    
    init(withProjectID id: String) {
        self.project = UOProject(withID: id)
        self.projectID = id
        self.urlImageModel = CachedImageModel(urlString: self.urlString)
    }
    
    func getImageURL() async -> String {
        var couter: Int8 = 10
        while true {
            let url: String? = self.project.imageURL
            if let url = url {
                print(url)
                self.urlImageModel.update(withURL: url)
                return url
            }
            try? await Task.sleep(nanoseconds: 1 * NSEC_PER_SEC)
            print("Error with Getting image URL | Project Cell №37")
            couter -= 1
            if couter == 0 {
                print("heh")
                self.urlImageModel.update(withURL: "https://firebasestorage.googleapis.com/v0/b/com-erast-coda.appspot.com/o/DefaultImage%2Fdefault1.png?alt=media&token=9faaa2d9-e37d-4d66-9422-d82081b43b0c")
                return "https://firebasestorage.googleapis.com/v0/b/com-erast-coda.appspot.com/o/DefaultImage%2Fdefault1.png?alt=media&token=9faaa2d9-e37d-4d66-9422-d82081b43b0c" }
        }
    }
    
    
    var colors : [Color] = [Color("BackgroundColor1"), Color("BackgroundColor2"), Color("BackgroundColor3"), Color("Register1"), Color.cyan, Color.purple, Color.yellow, Color.red, Color.green, Color.purple, Color.blue, Color.black, Color.gray]
    
    var body: some View {
        ZStack {
            ScrollView {}
                .background(.ultraThinMaterial)
                .background(LinearGradient(colors: [colors[Int(arc4random_uniform(UInt32(colors.count)))], colors[Int(arc4random_uniform(UInt32(colors.count)))], colors[Int(arc4random_uniform(UInt32(colors.count)))]], startPoint: .bottomTrailing, endPoint: .topLeading) )
            if let name = self.project.name, let description = self.project.description, let image = self.urlImageModel.image {
                VStack(alignment: .leading) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .scaledToFit()
                        .cornerRadius(15)
                        .padding()
                        .offset(y: -15)
                        .frame(height: 175)
                    VStack {
        
                        Text(name)
                            .foregroundColor(.primary)
                            .font(.custom("RobotoMono-SemiBold", size: 35))
                        Text(description)
                            .foregroundColor(.secondary)
                            .font(.custom("RobotoMono-Light", size: 20))
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            
                    }.frame(height: 75)
                        .offset(y: -40)
                        .padding(.horizontal, 10)
                        
                        
                    
                    
                }.frame(alignment: .top)
                    
        
            } else {
                ProgressView()
            }
            
        }.task {
            self.urlString = await getImageURL()
        }
        .frame(width: 200, height: 250)
        .cornerRadius(30)
    }
}

//struct ProjectCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectCell(withProject: Project(image: "violet", name: "Violet", description: "The maid for your iPhone"))
//    }
//}
