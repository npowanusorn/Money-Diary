//
//  WalletTypeRadioButton.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-09-18.
//

import UIKit

class WalletTypeRadioButton: UIButton {

    private var alternateButtons: [WalletTypeRadioButton]?
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = isSelected ? globalTintColor.cgColor : UIColor.secondarySystemBackground.cgColor
        }
    }

    override func awakeFromNib() {
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 2
        self.layer.masksToBounds = true
    }

    func unselectAlternateButtons() {
        if let alternateButtons = alternateButtons {
            self.isSelected = true
            for button in alternateButtons {
                button.isSelected = false
            }
        } else {
            toggleButton()
        }
    }

    func toggleButton() {
        self.isSelected.toggle()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
