//
//  Wallet.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import Foundation
import RealmSwift

class Wallet: Object {
    
    @objc dynamic private var _name = ""
    @objc dynamic private var _balance: Double = 0.0
    @objc dynamic private var _id = ""
    private var _type: WalletType = .unknown
    private var _dateCreated: Date = Date(timeIntervalSince1970: 0)
    private let _records = List<Record>()
    
    convenience init(name: String, balance: Double, type: WalletType, dateCreated: Date, id: String = generateUID()) {
        self.init()
        _name = name
        _balance = balance
        _id = id
        _type = type
        _dateCreated = dateCreated
    }
    
    var name: String {
        get { return _name }
        set { _name = newValue }
    }
    var balance: Double {
        get { return _balance }
    }
    var records: List<Record> {
        get { return _records }
    }
    var id: String {
        get { _id }
    }
    var type: WalletType {
        get { _type }
    }
    var dateCreated: Date {
        get { _dateCreated }
    }

    func modifyBalance(to newBalance: Double) {
        if newBalance < 0 { _balance = 0 }
        else { _balance = newBalance }
    }

    func modifyBalance(by change: Double) {
        _balance += change
        if _balance < 0 { _balance = 0 }
    }

    func modifyName(newName: String) {
        guard !newName.isEmpty else { return }
        _name = newName
    }

    func addRecord(newRecord: Record) {
        let recordAmount = newRecord.amount * (newRecord.isExpense ? -1.0 : 1.0)
        _records.append(newRecord)
        modifyBalance(by: recordAmount)
        RecordManager.shared.addRecord(newRecord: newRecord)
    }

    func getRecordsForDate(date: Date, filteredBy filter: FilterOption) -> List<Record> {
        let recordsForDate = List<Record>()
        for record in records {
            if Calendar.current.isDate(date, inSameDayAs: record.date) {
                recordsForDate.append(record)
            }
        }
        return getRecordsByType(recordsForDate, type: filter)
    }

    func getRecordsByType(_ records: List<Record>? = nil, type: FilterOption) -> List<Record> {
        let recordsByType = List<Record>()
        let records = records ?? self.records
        for record in records {
            switch type {
            case .all:
                recordsByType.append(record)
            case .expense:
                if record.isExpense {
                    recordsByType.append(record)
                }
            case .income:
                if !record.isExpense {
                    recordsByType.append(record)
                }
            }
        }
        return recordsByType
    }

    func getAllDates(filtered: FilterOption) -> [Date] {
        var allDates = [Date]()
        for record in records {
            if !allDates.contains(where: { date in
                Calendar.current.isDate(date, inSameDayAs: record.date)
            }), record.matchFilter(filter: filtered) {
                allDates.append(record.date)
            }
        }
        allDates.sort(by: >)
        return allDates
    }

    func removeRecord(at index: Int) -> Bool {
        guard index < _records.count else { return false }
        let recordToRemove = _records[index]
        let modifyBalanceAmount = recordToRemove.amount * (recordToRemove.isExpense ? 1.0 : -1.0)
        modifyBalance(by: modifyBalanceAmount)
        _records.remove(at: index)
        return true
    }

    func removeRecord(recordToRemove: Record) -> Bool {
        if let index = records.firstIndex(of: recordToRemove) {
            return removeRecord(at: index)
        }
        return false
    }
    
    static func ==(lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.id == rhs.id
    }
    
    func isSameWalletAs(wallet: Wallet) -> Bool {
        return self.id == wallet.id
    }

}
