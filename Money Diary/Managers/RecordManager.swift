//
//  RecordManager.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import Foundation

class RecordManager {

    static let shared = RecordManager()

    private init() { }

    private let walletManager = WalletManager.shared
    private var allRecords = [Record]()
    private var allDates = [Date]()

    func addRecord(newRecord: Record) {
        if !allDates.contains(where: { date in
            Calendar.current.isDate(newRecord.date, inSameDayAs: date)
        }) {
            allDates.append(newRecord.date)
        }
        allRecords.append(newRecord)
        allRecords.sort()
    }

    func getAllRecords() -> [Record] {
        return allRecords
    }

    func getAllDates() -> [Date] {
        return allDates
    }

    func getAllRecords(for date: Date) -> [Record] {
        var records = [Record]()
        for record in allRecords {
            if Calendar.current.isDate(date, inSameDayAs: record.date) {
                records.append(record)
            }
        }
        return records
    }
    
    func removeAllRecords() {
        allRecords.removeAll()
        allDates.removeAll()
    }
    
    func removeRecord(for wallet: Int) {
        var newRecords = [Record]()
        for record in allRecords {
            if record.wallet != wallet {
                newRecords.append(record)
            }
        }
        allRecords = newRecords
    }

//    func searchForRecord(by name: String) -> [Record] {
//        var list = [Record]()
//        for record in allRecords {
//            if ((record.note?.contains(name)) != nil) {
//                list.append(record)
//            }
//        }
//        return list
//    }
//
//    func removeRecord(recordToRemove: Record) -> Bool {
//        if let index = allRecords.firstIndex(of: recordToRemove) {
//            allRecords.remove(at: index)
//            return true
//        }
//        return false
//    }
}
