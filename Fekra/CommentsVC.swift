//
//  CommentsVC.swift
//  Fekra
//
//  Created by Sherif Kamal on 11/8/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentTxt: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var keyboardView: UIView!
    
    //MARK: Variables
    var thought: Thought!
    var comments = [Comment]()
    var thoughtRef: DocumentReference!
    var firestore = Firestore.firestore()
    var username: String!
    var commentlistener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        thoughtRef = firestore.collection(THOUGHTS_REF).document(thought.documentId)
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
        self.view.bindToKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        commentlistener = firestore.collection(THOUGHTS_REF)
            .document(self.thought.documentId)
            .collection(COMMENTS_REF)
            .order(by: TIMESTAMP, descending: false)
            .addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {
                debugPrint("Error Fetching comments: \(String(describing: error))")
                return
            }
            self.comments.removeAll()
            self.comments = Comment.parseData(snapshot: snapshot)
            self.tableView.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        commentlistener.remove()
    }
    
    @IBAction func addCommentBtnPressed(_ sender: Any) {
        guard let commentTxt = addCommentTxt.text else { return }
        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            let thoughtDoc: DocumentSnapshot
            do {
                try thoughtDoc = transaction.getDocument(self.firestore
                    .collection(THOUGHTS_REF)
                    .document(self.thought.documentId))
            } catch let error as NSError {
                debugPrint("Fetch error: \(error.localizedDescription)")
                return nil
            }
            guard let oldNumComments = thoughtDoc.data()?[NUM_COMMENTS] as? Int else { return nil }
            transaction.updateData([NUM_COMMENTS : oldNumComments + 1], forDocument: self.thoughtRef)
            let newCommentRef = self.firestore.collection(THOUGHTS_REF)
                .document(self.thought.documentId)
                .collection(COMMENTS_REF).document()
            transaction.setData([
                COMMENT_TXT : commentTxt,
                TIMESTAMP : FieldValue.serverTimestamp(),
                USERNAME : self.username,
                USER_ID : Auth.auth().currentUser?.uid ?? ""
                ], forDocument: newCommentRef)
            return nil
        }) { (object, error) in
            if let error = error {
                debugPrint("Transaction Failed: \(error)")
            } else {
                self.addCommentTxt.text = ""
                self.addCommentTxt.resignFirstResponder()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? UpdateCommentVC else { return }
        if let commentData = sender as? (comment: Comment, thought: Thought) {
            destination.commentData = commentData
        }
    }
}

extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as? CommentCell {
            
            cell.configureCell(comment: comments[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
}

extension CommentsVC: CommentDelegate {
    func commentOptionsTapped(comment: Comment) {
        let alert = UIAlertController(title: "Edit Comment", message: "You can delete or edit", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Comment", style: .default) { (action) in
            self.firestore.runTransaction({ (transaction, errorPointer) -> Any? in
                let thoughtDoc: DocumentSnapshot
                do {
                    try thoughtDoc = transaction.getDocument(self.firestore
                        .collection(THOUGHTS_REF)
                        .document(self.thought.documentId))
                } catch let error as NSError {
                    debugPrint("Fetch error: \(error.localizedDescription)")
                    return nil
                }
                guard let oldNumComments = thoughtDoc.data()?[NUM_COMMENTS] as? Int else { return nil }
                transaction.updateData([NUM_COMMENTS : oldNumComments - 1], forDocument: self.thoughtRef)
                let commentRef = self.firestore.collection(THOUGHTS_REF).document(self.thought.documentId)
                    .collection(COMMENTS_REF).document(comment.documentId)
                transaction.deleteDocument(commentRef)
                return nil
            }) { (object, error) in
                if let error = error {
                    debugPrint("Transaction Failed: \(error)")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        let editAction = UIAlertAction(title: "Edit Action", style: .default) { (action) in
            self.performSegue(withIdentifier: "toEditComment", sender: (comment, self.thought))
            alert.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        alert.addAction(deleteAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}
