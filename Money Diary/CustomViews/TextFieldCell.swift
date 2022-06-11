//
//  TextFieldCell.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-10.
//

import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet private var amountTextField: UITextField!
    
    var amountText: String {
        amountTextField.text ?? "0"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isSelected = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
