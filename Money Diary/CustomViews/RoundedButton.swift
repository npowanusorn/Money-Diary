//
//  RoundedButton.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-09.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    
    @IBInspectable let cornerRadius = 8.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        self.layer.cornerRadius = cornerRadius
        let imageView = UIImageView()
    }

}
