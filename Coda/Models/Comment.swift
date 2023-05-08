//
//  Comment.swift
//  Coda
//
//  Created by Matoi on 29.04.2023.
//

import SwiftUI

struct Comment: Identifiable {
    
    let id: UUID = UUID()
    
    let commentID: String?
    let personBeingReplied: String?
    let rootComment: String?
    let commentType: String?
    let author: String?
    let text: String?
    let upvotes: Array<String>?
    let downvotes: Array<String>?
    let replies: Array<String>?
    let image: String?
    let time: Double?
    let date: String?
    
}

