//
//  CustomTabBar.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-07-18.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class CustomTabBar: UIStackView {
    
    var itemTapped: Observable<Int> { itemTappedSubject.asObservable() }

    private let homeItem = CustomItemView(with: .home, index: 0)
    private let settingsItem = CustomItemView(with: .settings, index: 1)
    
    private lazy var itemViews: [CustomItemView] = [homeItem, settingsItem]
    
    private let itemTappedSubject = PublishSubject<Int>()
    private let dispose = DisposeBag()
    
    init() {
        super.init(frame: .zero)
        
        setupHierarchy()
        setupProperties()
        bind()
        
        setNeedsLayout()
        layoutIfNeeded()
        selectItem(index: 0)
    }
    
    private func setupHierarchy() {
        addArrangedSubviews([homeItem, settingsItem])
    }
    
    private func setupProperties() {
        distribution = .fillEqually
        alignment = .center
        
        backgroundColor = .systemGroupedBackground
        
        itemViews.forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            item.clipsToBounds = true
        }
    }
    
    private func selectItem(index: Int) {
        itemViews.forEach { $0.isSelected = $0.index == index }
        itemTappedSubject.onNext(index)
    }
    
    private func bind() {
        homeItem.rx.longPressGesture(configuration: {gestureRecognizer, delegate in
            gestureRecognizer.minimumPressDuration = 0.0
        }).when(.began).bind { [weak self] _ in
            guard let self = self else { return }
            self.homeItem.animateClickStart()
        }.disposed(by: dispose)
        
        homeItem.rx.longPressGesture().when(.began).bind { [weak self] _ in
            guard let self = self else { return }
            self.homeItem.animateClickStart()
            self.selectItem(index: self.homeItem.index)
        }.disposed(by: dispose)
        
        homeItem.rx.tapGesture().when(.ended).bind { [weak self] _ in
            guard let self = self else { return }
            self.homeItem.restoreAnimation()
            self.selectItem(index: self.homeItem.index)
        }.disposed(by: dispose)
        
        settingsItem.rx.longPressGesture(configuration: {gestureRecognizer, delegate in
            gestureRecognizer.minimumPressDuration = 0.0
        }).when(.began).bind { [weak self] _ in
            guard let self = self else { return }
            self.settingsItem.animateClickStart()
        }.disposed(by: dispose)
        
        settingsItem.rx.longPressGesture().when(.began).bind { [weak self] _ in
            guard let self = self else { return }
            self.settingsItem.animateClickStart()
            self.selectItem(index: self.settingsItem.index)
        }.disposed(by: dispose)
        
        settingsItem.rx.tapGesture().when(.ended).bind { [weak self] _ in
            guard let self = self else { return }
            self.settingsItem.restoreAnimation()
            self.selectItem(index: self.settingsItem.index)
        }.disposed(by: dispose)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
