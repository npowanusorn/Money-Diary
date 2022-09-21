//
//  TabBarController.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-07-18.
//

import UIKit
import SnapKit
import RxSwift

class TabBarController: UITabBarController {
    
    private let customTabBar = CustomTabBar()
    private let dispose = DisposeBag()
    private let controllers = CustomTabItem.allCases.map { UINavigationController(rootViewController: $0.viewController) }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupLayout()
        setupProperties()
        bind()
        view.layoutIfNeeded()
    }
    
    private func setupHierarchy() {
        view.addSubview(customTabBar)
    }
    
    private func setupLayout() {
        customTabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(90)
        }
    }
    
    private func setupProperties() {
        tabBar.isHidden = true
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        selectedIndex = 0
        setViewControllers(controllers, animated: true)
    }
    
    private func selectTab(index: Int) {
        if self.selectedIndex == index {
            controllers[index].popToRootViewController(animated: true)
        } else {
            self.selectedIndex = index
        }
    }
    
    private func bind() {
        customTabBar.itemTapped
            .bind { [weak self] in self?.selectTab(index: $0) }
            .disposed(by: dispose)
    }
    
}
