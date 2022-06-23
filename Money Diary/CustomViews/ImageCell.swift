//
//  ImageCell.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 22/06/2022.
//

import UIKit

class ImageCell: UITableViewCell {

    @IBOutlet private var cellImageView: UIImageView!
    @IBOutlet private var primaryLabel: UILabel!
    @IBOutlet private var secondaryLabel: UILabel!
    @IBOutlet private var subLabel: UILabel!

    var cellImage: UIImage? {
        get { return cellImageView.image }
        set {
            cellImageView.image = newValue
            cellImageView.isHidden = newValue == nil
        }
    }

    var primaryText: String {
        get { return primaryLabel.text ?? "" }
        set {
            primaryLabel.text = newValue
            primaryLabel.isHidden = newValue.isEmpty
        }
    }

    var secondaryText: String {
        get { return secondaryLabel.text ?? "" }
        set {
            secondaryLabel.text = newValue
            secondaryLabel.isHidden = newValue.isEmpty
        }
    }

    var subText: String {
        get { return subLabel.text ?? "" }
        set {
            subLabel.text = newValue
            subLabel.isHidden = newValue.isEmpty
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
