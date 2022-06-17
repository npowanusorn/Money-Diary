//
//  TextViewCell.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-11.
//

import UIKit

protocol TextViewCellDelegate {
    func textViewDidChange(text: String)
}

class TextViewCell: UITableViewCell {

    @IBOutlet private var notesTextView: UITextView!
    @IBOutlet private var placeholderLabel: UILabel!
    var delegate: TextViewCellDelegate?
    
    var notesText: String {
        notesTextView.text
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notesTextView.delegate = self
        placeholderLabel.isHidden = notesTextView.hasText
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.font = UIFont(name: "Avenir Next Regular", size: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension TextViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange(text: textView.text)
        if textView.text.isEmpty {
            placeholderLabel.text = "Notes"
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
        let info: [String: CGFloat] = ["height": textView.contentSize.height]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "textViewDidChange"), object: nil, userInfo: info)
    }
}
