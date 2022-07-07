//
//  Record.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import Foundation
import RealmSwift

class Record: Object, Comparable {
    @objc dynamic private var _amount: Double = 0.0
    @objc dynamic private var _note: String? = ""
    @objc dynamic private var _date: Date = Date()
    @objc dynamic private var _wallet: Int = 0
    @objc dynamic private var _isExpense: Bool = true
    
    var amount: Double {
        get { _amount }
        set { _amount = newValue }
    }
    var note: String? {
        get { _note }
        set { _note = newValue }
    }
    var date: Date {
        get { _date }
        set { _date = newValue }
    }
    var wallet: Int {
        get { _wallet }
        set { _wallet = newValue }
    }
    var isExpense: Bool {
        get { _isExpense }
        set { _isExpense = newValue }
    }

    convenience init(amount: Double, note: String?, date: Date, wallet: Int, isExpense: Bool) {
        self.init()
        _amount = amount
        _note = note
        _date = date
        _wallet = wallet
        _isExpense = isExpense
    }

    static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs.date == rhs.date && lhs.isExpense == rhs.isExpense && lhs.amount == rhs.amount && lhs.note == rhs.note
    }

    static func < (lhs: Record, rhs: Record) -> Bool {
        return lhs.date < rhs.date
    }
}
