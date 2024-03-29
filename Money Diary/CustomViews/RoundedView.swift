//
//  RoundedView.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-06.
//

import UIKit

@IBDesignable class RoundedView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 12 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = cornerRadius
    }

    override class func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}
