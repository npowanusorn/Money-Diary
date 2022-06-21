//
//  SwipeTabView.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-19.
//

import UIKit

protocol SwipeTabViewDelegate {
    func didChangeToIndex(index: Int)
}

enum SelectionBarOrientation {
    case top
    case bottom
}

class TabBarView: UIView {
    
    private var buttonTitles: [String]!
    private var buttons: [UIButton]!
    private var selectionView: UIView!
    private var selectionViewOrientation: SelectionBarOrientation = .top
    
    var textColor: UIColor = .secondaryLabel
    var selectionViewColor: UIColor = .tintColor
    var selectedTextColor: UIColor = .label
    var delegate: SwipeTabViewDelegate?

    convenience init(frame: CGRect, buttonTitles: [String], selectionOrientation: SelectionBarOrientation = .bottom) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitles
    }
            
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView()
    }
        
    func setButtonTitles(buttonTitles: [String]) {
        self.buttonTitles = buttonTitles
        updateView()
    }
    
    func setSelectionOrientation(to orientation: SelectionBarOrientation) {
        self.selectionViewOrientation = orientation
        updateView()
    }
    
    private func updateView() {
        setupButton()
        setupSelectorView()
        setupStackView()
    }
    
    private func setupStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        stack.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        stack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        NSLayoutConstraint(item: stack, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.75, constant: 0).isActive = true
//        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
//        stack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        stack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    private func setupSelectorView() {
        let selectionWidth = frame.width / CGFloat(buttonTitles.count)
        var yPos: CGFloat {
            switch selectionViewOrientation {
            case .bottom:
                return self.frame.height
            case .top:
                return 0
            }
        }
        selectionView = UIView(frame: CGRect(x: 0, y: yPos, width: selectionWidth, height: 2))
        selectionView.backgroundColor = selectionViewColor
        addSubview(selectionView)
    }
    
    private func setupButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        for title in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = K.Fonts.avenirNextRegular15
            buttons.append(button)
        }
        buttons[0].setTitleColor(selectedTextColor, for: .normal)
    }
    
    @objc
    func buttonAction(_ sender: UIButton) {
        for (buttonIndex, button) in buttons.enumerated() {
            button.setTitleColor(textColor, for: .normal)
            if button == sender {
                delegate?.didChangeToIndex(index: buttonIndex)
                let selectionPosition = frame.width / CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3) {
                    self.selectionView.frame.origin.x = selectionPosition
                }
                button.setTitleColor(selectedTextColor, for: .normal)
            }
        }
    }

}
