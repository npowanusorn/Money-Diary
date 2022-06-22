//
//  Record.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import Foundation

struct Record: Equatable {
    var amount: Double
    var notes: String
    var date: Date
    var walletIndex: Int
    var isExpense: Bool
}
