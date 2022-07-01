//
//  TabBarView.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-19.
//

import UIKit

protocol TabBarViewDelegate {
    func didChangeToIndex(index: Int)
}

struct TabBarViewConfiguration {
    let frame: CGRect
    let buttonTitles: [String]
    let orientation: TabBarView.SelectionBarOrientation
    let style: TabBarView.SelectionStyle
}

class TabBarView: UIView {

    private var buttonTitles: [String]!
    private var buttons: [UIButton]!
    private var selectionView: UIView!
    private var selectionViewOrientation: SelectionBarOrientation = .top
    private var selectionStyle: SelectionStyle = .line
    private var textColor: UIColor = .secondaryLabel
    private var selectionViewColor: UIColor = globalTintColor
    private var selectedTextColor: UIColor = .label
    private var selectedIndex: Int = 0

    var delegate: TabBarViewDelegate?

    convenience init(config: TabBarViewConfiguration) {
        self.init(frame: config.frame)
        self.buttonTitles = config.buttonTitles
        self.selectionStyle = config.style
        self.selectionViewOrientation = config.orientation
    }

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

    func setStyle(style: SelectionStyle) {
        self.selectionStyle = style
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
//        stack.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        stack.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
//        stack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//        NSLayoutConstraint(item: stack, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.75, constant: 0).isActive = true
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    private func setupSelectorView() {
        let selectionWidth = frame.width / CGFloat(buttonTitles.count)
        var yPos: CGFloat {
            if case .fill = selectionStyle {
                return 0
            }
            switch selectionViewOrientation {
            case .bottom:
                return self.frame.height
            case .top:
                return 0
            }
        }
        var height: CGFloat {
            switch selectionStyle {
            case .line:
                return 2
            case .fill:
                return self.frame.height
            }
        }
        selectionView = UIView(frame: CGRect(x: selectionWidth * CGFloat(selectedIndex), y: yPos, width: selectionWidth, height: height))
        selectionView.backgroundColor = selectionViewColor
        if case .fill = selectionStyle {
            selectionView.layer.cornerRadius = 12.0
        }
        addSubview(selectionView)
        sendSubviewToBack(selectionView)
    }
    
    private func setupButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        for title in buttonTitles {
            var configuration = UIButton.Configuration.plain()
            configuration.title = title
//            configuration.attributedTitle =
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.setTitleColor(textColor, for: .normal)
//            button.titleLabel?.font = K.Fonts.regular.getFont(size: 15)
            buttons.append(button)
        }
        buttons[selectedIndex].setTitleColor(selectedTextColor, for: .normal)
    }
    
    @objc
    func buttonAction(_ sender: UIButton) {
        for (buttonIndex, button) in buttons.enumerated() {
            button.setTitleColor(textColor, for: .normal)
            if button == sender {
                delegate?.didChangeToIndex(index: buttonIndex)
                let selectionPosition = frame.width / CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
                selectedIndex = buttonIndex
                UIView.animate(withDuration: 0.3) {
                    self.selectionView.frame.origin.x = selectionPosition
                }
                button.setTitleColor(selectedTextColor, for: .normal)
            }
        }
    }

}

extension TabBarView {
    enum SelectionStyle {
        case fill
        case line
    }

    enum SelectionBarOrientation {
        case top
        case bottom
    }

}
