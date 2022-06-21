//
//  CommonExtensions.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 20/06/2022.
//

import Foundation

extension String {
    func toCurrencyFormat() -> String {
        let formattedString = String(format: "$%.2f", self)
        return "\(formattedString)"
    }
}

extension Double {
    func toCurrencyString() -> String {
        let string = String(format: "$%.2f", self)
        return string
    }
}
