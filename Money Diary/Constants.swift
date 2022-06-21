//
//  Constants.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-19.
//

import UIKit
import SwiftyBeaver

public var Log = SwiftyBeaver.self

enum K {
    
    enum Fonts: String {
        case bold = "Bold"
        case regular = "Regular"
        case demiBold = "Demi Bold"
        case medium = "Medium"

        func getFont(size: CGFloat) -> UIFont {
            let font = UIFont(name: "Avenir Next \(self.rawValue)", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
            return font
        }
//        static let avenirNextRegular17 = UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
//        static let avenirNextRegular15 = UIFont(name: "Avenir Next Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
    }
    
    struct CellID {
        
    }
            
}

enum FilterOption {
    case all
    case expense
    case income
}
