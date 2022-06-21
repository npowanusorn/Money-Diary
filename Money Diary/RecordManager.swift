//
//  RecordManager.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import Foundation

class RecordManager {

    static let shared = RecordManager()

    private init() {
        allRecords = [Record]()
        allDates = [Date]()
        for record in walletManager.getRecordsForWallet() {
            self.addRecord(newRecord: record)
        }
    }

    private let walletManager = WalletManager.shared
    private var allRecords: [Record]
    private var allDates: [Date]

    func addRecord(newRecord: Record) {
        let index = newRecord.walletIndex
        let recordDate = newRecord.date
        if !allDates.contains(where: { date in
            Calendar.current.isDate(recordDate, inSameDayAs: date)
        }) {
            allDates.append(recordDate)
        }
        walletManager.modifyBalance(ofWalletIndex: index, by: newRecord.amount, operation: .subtract)
        walletManager.addRecordToWallet(record: newRecord)
        allRecords.append(newRecord)
        allRecords.sort { record1, record2 in
            record1.date.compare(record2.date) == .orderedDescending
        }
    }
    
    func getAllRecords() -> [Record] {
        return allRecords
    }
    
    func getAllRecords(forWalledIndex walletIndex: Int) -> [Record] {
        var list = [Record]()
        for record in allRecords {
            if record.walletIndex == walletIndex {
                list.append(record)
            }
        }
        return list
    }
    
    func getAllRecords(forDate date: Date) -> [Record] {
        var records = [Record]()
        for record in allRecords {
            if Calendar.current.isDate(record.date, inSameDayAs: date) {
                records.append(record)
            }
        }
        return records
    }
    
    func getAllRecords(for date: Date, in walletIndex: Int) -> [Record] {
        let recordsForWallet = getAllRecords(forWalledIndex: walletIndex)
        var recordsForWalletInDate = [Record]()
        for record in recordsForWallet {
            if Calendar.current.isDate(record.date, inSameDayAs: date) {
                recordsForWalletInDate.append(record)
            }
        }
        return recordsForWalletInDate
    }
    
    func getRecord(from walletIndex: Int, with name: String) -> Record? {
        let list = walletManager.getWallet(at: walletIndex).records
        for item in list {
            if item.notes == name {
                return item
            }
        }
        return nil
    }
    
    func getAllDatesSorted(for walletIndex: Int? = nil) -> [Date] {
        if let index = walletIndex {
            let recordsForWallet = getAllRecords(forWalledIndex: index)
            var recordsDate = [Date]()
            for record in recordsForWallet {
                if !recordsDate.contains(where: { date in
                    Calendar.current.isDate(date, inSameDayAs: record.date)
                }) {
                    recordsDate.append(record.date)
                }
            }
            return recordsDate
        }
        return allDates.sorted(by: >)
    }
    
    func addMockRecords(count: Int, walletIndex: Int) {
        for counter in 1...count {
            let record = Record(amount: Double.random(in: 1...100), notes: "tr \(counter)", date: Date(), walletIndex: walletIndex, isExpense: Bool.random())
            addRecord(newRecord: record)
        }
    }
    
    func searchForRecord(by name: String) -> [Record] {
        var list = [Record]()
        for record in allRecords {
            if record.notes.contains(name) {
                list.append(record)
            }
        }
        return list
    }
}
