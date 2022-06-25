//
//  TextFields.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 24/06/2022.
//

import UIKit

@IBDesignable
class BaseTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyStyles()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyles()
    }

    func applyStyles() {
        self.borderStyle = .none
        self.autocorrectionType = .no
        self.spellCheckingType = .no

        self.layer.cornerRadius = 12.0
        self.layer.masksToBounds = true
        self.clipsToBounds = false
        self.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.textColor = .label
    }

}

@IBDesignable
class PasswordTextField: BaseTextField {
    override func applyStyles() {
        super.applyStyles()

        self.textContentType = .oneTimeCode
        let showPasswordImage = UIImage(named: "Show Password")?.withRenderingMode(.alwaysTemplate).resize(newHeight: 20).withTintColor(.label)
        let hidePasswordImage = UIImage(named: "Hide Password")?.withRenderingMode(.alwaysTemplate).resize(newHeight: 20).withTintColor(.label)
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.setImage(showPasswordImage, for: UIButton.State())
        button.setImage(hidePasswordImage, for: .selected)
        let rightView = button
        rightView.contentMode = .scaleAspectFit
        rightView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.rightView = rightView
        self.rightViewMode = .always
    }

    @objc
    func buttonTapped(_ button: UIButton) {
        self.isSecureTextEntry.toggle()
        button.isSelected.toggle()
    }

}
