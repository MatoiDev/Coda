//
//  OrderConstructor.swift
//  Coda
//
//  Created by Matoi on 01.02.2023.
//

import SwiftUI


/*
 
 Order [Freelance]
 - id: String
 - title: String
 - description: String
 - customerID: userID
 - reward: String || Int
 - topic: FreelanceTopic (enum)
 - dateOfPublish: String
 - responses:  Int
 - views: Int
 - upvotes: Int
 - descriptors: [LangDescriptor]
 - imageExamplesURLs: [String]    —>    In Storage: FreelanceOrdersExamples
 
 */

enum FreelanceOrderTypeReward {
    case negotiated
    case specified(price: Int)
}

enum FreelanceTopic {
    case Development
    case Design
    case Administration
    case Testing
}

struct OrderConstructor: View {
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var reward: FreelanceOrderTypeReward = .negotiated
    @State private var price: Int?
    @State private var topic: FreelanceTopic = .Development
    @State private var images: [UIImage]?
    
    var body: some View {
        List {
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("New Order")
                        .robotoMono(.semibold, 18)
                    Text("[Constructor]")
                        .robotoMono(.medium, 13, color: .secondary)
                }
                
            }
        }
    }
}
#if DEBUG
struct OrderConstructor_Previews: PreviewProvider {
    static var previews: some View {
        OrderConstructor()
    }
}
#endif
