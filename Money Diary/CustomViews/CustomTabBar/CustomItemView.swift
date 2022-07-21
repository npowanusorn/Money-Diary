//
//  CustomItemView.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-07-18.
//

import UIKit
import SnapKit

class CustomItemView: UIView {

    private let nameLabel = UILabel()
    private let iconView = UIImageView()
    private let underlineView = UIView()
    private let containerView = UIView()
    let index: Int
    
    var isSelected = false {
        didSet { animateItem() }
    }
    
    private let item: CustomTabItem
    
    init(with item: CustomTabItem, index: Int) {
        self.item = item
        self.index = index
        
        super.init(frame: .zero)
        
        setupHierarchy()
        setupLayout()
        setupProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHierarchy() {
        addSubview(containerView)
        containerView.addSubviews(nameLabel, iconView, underlineView)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        iconView.snp.makeConstraints { make in
            make.height.width.equalTo(30)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalTo(nameLabel.snp.top)
            make.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(16)
        }
        
        underlineView.snp.makeConstraints { make in
            make.width.equalTo(iconView.snp.width)
            make.height.equalTo(4)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(nameLabel.snp.centerY)
        }
    }
    
    private func setupProperties() {
        nameLabel.text = item.title
        nameLabel.textAlignment = .center
        nameLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        nameLabel.textColor = globalTintColor
        underlineView.backgroundColor = globalTintColor
        underlineView.layer.cornerRadius = 2
        iconView.image = isSelected ? item.selectedImage : item.image
    }
    
    func animateItem() {
        UIView.animate(withDuration: 0.2) {
            self.nameLabel.alpha = self.isSelected ? 0.0 : 1.0
            self.underlineView.alpha = self.isSelected ? 1.0 : 0.0
        }
        UIView.transition(with: iconView, duration: 0.2, options: .transitionCrossDissolve) {
            self.iconView.image = self.isSelected ? self.item.selectedImage : self.item.image
        }
    }
}
