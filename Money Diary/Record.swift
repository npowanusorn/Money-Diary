//
//  Record.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import Foundation

class Record: Equatable, Comparable {

    var amount: Double
    var note: String?
    var date: Date
    var wallet: Wallet
    var isExpense: Bool

    init(amount: Double, note: String?, date: Date, wallet: Wallet, isExpense: Bool) {
        self.amount = amount
        self.note = note
        self.date = date
        self.wallet = wallet
        self.isExpense = isExpense
    }

    static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs.date == rhs.date && lhs.isExpense == rhs.isExpense && lhs.amount == rhs.amount && lhs.note == rhs.note
    }

    static func < (lhs: Record, rhs: Record) -> Bool {
        return lhs.date < rhs.date
    }
}
