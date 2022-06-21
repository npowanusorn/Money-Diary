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
    
    var isBalanceHidden: Bool {
        get { walletBalanceLabel.isHidden }
        set { walletBalanceLabel.isHidden = newValue }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func makeNameLabelBold() {
        walletNameLabel.font = UIFont.boldSystemFont(ofSize: walletNameLabel.font.pointSize)
    }
}
