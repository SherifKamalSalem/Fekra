//
//  Comment.swift
//  Fekra
//
//  Created by Sherif Kamal on 11/8/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    private(set) var username: String!
    private(set) var timestamp: Date!
    private(set) var commentTxt: String!
    private(set) var documentId: String!
    private(set) var userId: String!
    
    init(username: String, timestamp: Date, commentTxt: String, documentId: String, userId: String) {
        self.username = username
        self.timestamp = timestamp
        self.commentTxt = commentTxt
        self.documentId = documentId
        self.userId = userId
    }
    
    class func parseData(snapshot: QuerySnapshot?) -> [Comment] {
        var comments = [Comment]()
        guard let snapshot = snapshot else { return comments}
        for document in snapshot.documents {
            let data = document.data()
            let username = data[USERNAME] as? String ?? "Anonymous"
            let timestamp = data[TIMESTAMP] as? Date ?? Date()
            let commentTxt = data[COMMENT_TXT] as? String ?? ""
            let documentId = document.documentID
            let userId = data[USER_ID] as? String ?? ""
            
            let newComment = Comment(username: username, timestamp: timestamp, commentTxt: commentTxt, documentId: documentId, userId: userId)
            comments.append(newComment)
        }
        return comments
    }
}
