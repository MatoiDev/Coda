//
//  IdeaCellView.swift
//  Coda
//
//  Created by Matoi on 01.04.2023.
//

import SwiftUI

struct IdeaCellView: View {
    private let idea: Idea
    init (for idea: Idea) {
        self.idea = idea
        
    }
    var body: some View {
        Text(idea.title)
    }
}

struct IdeaCellView_Previews: PreviewProvider {
    static var previews: some View {
        IdeaCellView(for: Idea(id: "123", author: "Matoi", title: "Write a simple Siri customizer", text: "The Idea's Body", category: "Development", subcategory: "iOS", difficultyLevel: "Lead", skills: "Xcode, AppCode, Logos, iOS", languages: ["Objective-C", "Logos", "Swift"], images: [], files: [], comments: [], stars: [], responses: [], views: [], saves: [], dateOfPublish: "1 Apr at 13:49"))
    }
}
