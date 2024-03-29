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
    @objc dynamic private var _walletID = ""
    @objc dynamic private var _isExpense: Bool = true
    @objc dynamic private var _id = ""
    private var _currency: CurrencyType = .CAD
    
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
    var walletID: String {
        get { _walletID }
        set { _walletID = newValue }
    }
    var isExpense: Bool {
        get { _isExpense }
        set { _isExpense = newValue }
    }
    var id: String {
        get { _id }
    }
    var currency: CurrencyType {
        get { _currency }
    }

    convenience init(amount: Double, note: String?, date: Date, walletID: String, isExpense: Bool, currency: CurrencyType, id: String = generateUID()) {
        self.init()
        _amount = amount
        _note = note
        _date = date
        _walletID = walletID
        _isExpense = isExpense
        _id = id
        _currency = currency
    }

    static func == (lhs: Record, rhs: Record) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Record, rhs: Record) -> Bool {
        return lhs.date < rhs.date
    }
    
    func matchFilter(filter: FilterOption) -> Bool {
        switch filter {
        case .all:
            return true
        case .expense:
            return self.isExpense
        case .income:
            return !self.isExpense
        }
    }
}
