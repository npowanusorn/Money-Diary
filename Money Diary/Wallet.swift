//
//  Wallet.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import Foundation

class Wallet {
    private var _name: String
    private var _balance: Double
    private var _records: [Record]
    var name: String {
        get { return _name }
        set { _name = newValue }
    }
    var balance: Double {
        get { return _balance }
    }
    var records: [Record] {
        get { return _records }
    }

    init(name: String, balance: Double, records: [Record]? = nil) {
        self._name = name
        self._balance = balance
        self._records = records ?? [Record]()
    }

    func modifyBalance(to newBalance: Double) {
        if newBalance < 0 { _balance = 0 }
        else { _balance = newBalance }
    }

    func modifyBalance(by change: Double) {
        Log.info("balance before: \(_balance)")
        _balance += change
        Log.info("balance after: \(_balance)")
        if _balance < 0 { _balance = 0 }
    }

    func addRecord(newRecord: Record) {
        Log.info("newRecord.amount: \(newRecord.amount)")
        let recordAmount = newRecord.amount * (newRecord.isExpense ? -1.0 : 1.0)
        Log.info("recordAmount: \(recordAmount)")
        _records.append(newRecord)
        modifyBalance(by: recordAmount)
        RecordManager.shared.addRecord(newRecord: newRecord)
    }

    func getRecordsForDate(date: Date) -> [Record] {
        var recordsForDate = [Record]()
        for record in records {
            if Calendar.current.isDate(date, inSameDayAs: record.date) {
                recordsForDate.append(record)
            }
        }
        return recordsForDate
    }

    func getRecordsByType(type: FilterOption) -> [Record] {
        var recordsByType = [Record]()
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

    func getAllDates() -> [Date] {
        var allDates = [Date]()
        for record in records {
            if !allDates.contains(where: { date in
                Calendar.current.isDate(date, inSameDayAs: record.date)
            }) {
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

}
