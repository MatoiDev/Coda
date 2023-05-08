//
//  CommentsViewExpanded.swift
//  Coda
//
//  Created by Matoi on 02.05.2023.
//

import SwiftUI

struct CommentsViewExpanded: View {
    let mainComment: Comment
    let replies: Array<Comment>
    
    init(withMainComment comment: Comment, replies: Array<Comment>) {
        self.mainComment = comment
        self.replies = replies
    }
    
    var body: some View {
        ScrollView {
            
        }
    }
}

//struct CommentsViewExpanded_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentsViewExpanded()
//    }
//}
