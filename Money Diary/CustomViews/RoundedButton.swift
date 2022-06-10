//
//  RoundedButton.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-09.
//

import UIKit

class RoundedButton: UIButton {
    
    let cornerRadius = 8.0
    
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
        self.backgroundColor = .systemBlue
        self.titleLabel?.font = UIFont(name: "Avenir Next Regular", size: 18)
        self.setTitleColor(.white, for: .normal)
        self.setTitle("Add", for: .normal)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
