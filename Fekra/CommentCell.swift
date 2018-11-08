//
//  CommentCell.swift
//  Fekra
//
//  Created by Sherif Kamal on 11/8/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var commentTxtLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    
    
    func configureCell(comment: Comment) {
        usernameLbl.text = comment.username
        commentTxtLbl.text = comment.commentTxt
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: comment.timestamp)
        timestampLbl.text = timestamp
        
    }
}
