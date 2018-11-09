//
//  AddThoughtVC.swift
//  Fekra
//
//  Created by Sherif Kamal on 11/8/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import Firebase

class AddThoughtVC: UIViewController {

    //MARK: Outlets
    @IBOutlet private weak var categorySegment: UISegmentedControl!
    @IBOutlet private weak var thoughtTxt: UITextView!
    @IBOutlet private weak var postBtn: UIButton!
    //MARK: Variables
    private var selectedCategory = ThoughtCategory.funny.rawValue
    var thoughtData: Thought?
    var isEditable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postBtn.layer.cornerRadius = 5
        thoughtTxt.layer.cornerRadius = 5
        thoughtTxt.text = "My random thought..."
        thoughtTxt.textColor = UIColor.lightGray
        thoughtTxt.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let thoughtData = thoughtData else { return }
        let thoughtRef = Firestore.firestore().collection(THOUGHTS_REF).document(thoughtData.documentId)
        thoughtRef.getDocument { (document, error) in
            if let document = document, document.exists, document.get("userId") as? String == Auth.auth().currentUser?.uid {
                self.isEditable = true
                self.postBtn.setTitle("Update", for: .normal)
                self.thoughtTxt.text = thoughtData.thoughtTxt
            }
        }
    }
    
    //MARK: IBActions
    @IBAction func postBtnPressed(_ sender: Any) {
        if isEditable {
            Firestore.firestore().collection(THOUGHTS_REF).document(thoughtData!.documentId).updateData([THOUGHT_TXT : thoughtTxt.text]) { (error) in
                if let error = error {
                    debugPrint("Unable to update thought: \(error.localizedDescription)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            Firestore.firestore().collection(THOUGHTS_REF).addDocument(data:
                [CATEGORY : selectedCategory,
                 NUM_COMMENTS : 0,
                 NUM_LIKES : 0,
                 THOUGHT_TXT : thoughtTxt.text,
                 TIMESTAMP : FieldValue.serverTimestamp(),
                 USERNAME : Auth.auth().currentUser?.displayName ?? "",
                 USER_ID : Auth.auth().currentUser?.uid ?? ""
                ])
            { (error) in
                if let error = error {
                    debugPrint("Error adding document: \(error)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func categorySegmentChanged(_ sender: Any) {
        switch categorySegment.selectedSegmentIndex {
        case 0:
            selectedCategory = ThoughtCategory.funny.rawValue
        case 1:
            selectedCategory = ThoughtCategory.serious.rawValue
        default:
            selectedCategory = ThoughtCategory.crazy.rawValue
        }
    }
}

extension AddThoughtVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.darkGray
    }
}
