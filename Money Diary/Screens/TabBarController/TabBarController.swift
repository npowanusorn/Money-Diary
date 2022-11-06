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
    private let gradientView = UIView(
        frame: CGRect(
            x: 0,
            y: ScreenSize.height - Constants.tabBarHeight - Constants.offset,
            width: ScreenSize.width,
            height: Constants.tabBarHeight + Constants.offset
        )
    )

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
        view.addSubviews(gradientView, customTabBar)
    }
    
    private func setupLayout() {
        customTabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Constants.tabBarHeight)
        }
    }
    
    private func setupProperties() {
        tabBar.isHidden = true
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(1).cgColor]
        gradient.startPoint = CGPoint(x: Constants.xPoint, y: Constants.startPointY)
        gradient.endPoint = CGPoint(x: Constants.xPoint, y: Constants.endPointY)
        gradientView.layer.mask = gradient
        gradientView.layer.insertSublayer(gradient, at: 0)
        gradientView.isUserInteractionEnabled = false
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

private enum Constants {
    static let tabBarHeight: CGFloat = 90
    static let offset: CGFloat = 40
    static let xPoint = 0.5
    static let startPointY = 0.0
    static let endPointY = 0.8
}
