//
//  WalletsCell.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-06.
//

import UIKit

class WalletsCell: UITableViewCell {

    @IBOutlet private var walletNameLabel: UILabel!
    @IBOutlet private var walletBalanceLabel: UILabel!
    
    var walletName: String {
        get { walletNameLabel.text ?? "" }
        set { walletNameLabel.text = newValue }
    }
    
    var walletBalance: String {
        get { walletBalanceLabel.text ?? "" }
        set { walletBalanceLabel.text = newValue }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
