//
//  CustomTabItem.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-07-18.
//

import UIKit

enum CustomTabItem: String, CaseIterable {
    case home, settings
}

extension CustomTabItem {
    var viewController: UIViewController {
        switch self {
        case .home:
            return DashboardVC()
        case .settings:
            return SettingsVC()
        }
    }
    
    var image: UIImage {
        switch self {
        case .home:
            return UIImage(systemName: "house")?.withTintColor(globalTintColor, renderingMode: .alwaysOriginal) ?? UIImage()
        case .settings:
            return UIImage(systemName: "gearshape")?.withTintColor(globalTintColor, renderingMode: .alwaysOriginal) ?? UIImage()
        }
    }
    
    var selectedImage: UIImage {
        switch self {
        case .home:
            return UIImage(systemName: "house.fill")?.withTintColor(globalTintColor, renderingMode: .alwaysOriginal) ?? UIImage()
        case .settings:
            return UIImage(systemName: "gearshape.fill")?.withTintColor(globalTintColor, renderingMode: .alwaysOriginal) ?? UIImage()
        }
    }
    
    var title: String { return self.rawValue.capitalized }
}
