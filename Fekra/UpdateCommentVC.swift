//
//  UpdateCommentVC.swift
//  Fekra
//
//  Created by Sherif Kamal on 11/9/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import Firebase

class UpdateCommentVC: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var commentTxt: UITextView!
    @IBOutlet weak var updateBtn: UIButton!
    //MARK: Variables
    var commentData: (comment: Comment, thought: Thought)!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTxt.layer.cornerRadius = 8
        updateBtn.layer.cornerRadius = 8
        commentTxt.text = commentData.comment.commentTxt
    }
    
    @IBAction func updateBtnPressed(_ sender: Any) {
        Firestore.firestore().collection(THOUGHTS_REF).document(commentData.thought.documentId)
            .collection(COMMENTS_REF).document(commentData.comment.documentId).updateData([COMMENT_TXT : commentTxt.text]) { (error) in
                if let error = error {
                    debugPrint("Unable to update comment: \(error.localizedDescription)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
        }
    }
}
