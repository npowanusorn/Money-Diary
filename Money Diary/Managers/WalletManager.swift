//
//  WalletManager.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import Foundation

enum Operation {
    case add
    case subtract
}

enum WalletSort {
    case wallet
    case date
}

class WalletManager {

    static let shared = WalletManager()

    private init() { }

    private var wallets = [Wallet]()
//    private let recordManager = RecordManager.shared

    var chosenWalletIndex = 0
//    var chosenWallet: Wallet {
//        getWallet(at: chosenWalletIndex)
//    }
    
    var sortBy: WalletSort = .wallet

    var numberOfWallets: Int {
        return wallets.count
    }

    func getWallets() -> [Wallet] {
        return wallets
    }

    func getWallet(at index: Int) -> Wallet {
        return wallets[index]
    }
    
    func getWallet(by id: String) -> Wallet? {
        for wallet in wallets {
            if wallet.id == id {
                return wallet
            }
        }
        return nil
    }

    func addWallet(newWallet: Wallet) {
        wallets.append(newWallet)
    }

    func addMockWallets(count: Int) {
        for counter in 1...count {
            let wallet = Wallet(name: "wallet \(counter)", balance: 1000.0)
            addWallet(newWallet: wallet)
        }
    }

//    func addMockRecords(count: Int, walletIndex: Int) {
//        let wallet = getWallet(at: walletIndex)
//        for counter in 1...count {
//            let record = Record(
//                amount: Double.random(in: 1...100).rounded(toPlaces: 2),
//                note: "tr \(counter)", date: Date(),
//                wallet: walletIndex,
//                isExpense: Bool.random()
//            )
//            wallet.addRecord(newRecord: record)
//        }
//    }
    
    func addRecordToWallet(record: Record) {
        guard let wallet = getWallet(by: record.walletID) else { return }
        wallet.addRecord(newRecord: record)
    }

//    func updateBalance(ofWalletIndex index: Int, with balance: Double) {
//        getWallet(at: index).modifyBalance(to: balance)
//    }

//    func modifyBalance(ofWalletIndex index: Int, by balance: Double, operation: Operation) {
//        getWallet(at: index).modifyBalance(by: balance, with: operation)
//    }

//    func addRecordToWallet(record: Record) {
//        record.wallet.records.append(record)
//        record.wallet.records.sort()
//        recordManager.addRecord(newRecord: record)
//    }
    
    func removeWallet(at index: Int) -> Bool {
        guard numberOfWallets > 0, index < numberOfWallets, index >= 0 else { return false }
        let wallet = wallets[index]
        wallets.remove(at: index)
        if chosenWalletIndex > index {
            chosenWalletIndex -= 1
        } else if chosenWalletIndex == index {
            chosenWalletIndex = 0
        }
        RecordManager.shared.removeRecord(for: wallet.id)
        return true
    }
    
    func removeAllWallets() {
        wallets.removeAll()
    }

//    func getRecords(for walletIndex: Int? = nil) -> [Record] {
//        if let walletIndex = walletIndex {
//            let wallet = getWallet(at: walletIndex)
//            return wallet.records
//        } else {
//            var records = [Record]()
//            for wallet in wallets {
//                records += wallet.records
//            }
//            return records
//        }
//    }

//    func getRecords(for date: Date) -> [Record] {
//        var recordsForDate = [Record]()
//        for wallet in getWallets() {
//            for record in wallet.records {
//                if Calendar.current.isDate(record.date, inSameDayAs: date) {
//                    recordsForDate.append(record)
//                }
//            }
//        }
//        return recordsForDate
//    }
//
//    func getRecords(for date: Date, in walletIndex: Int) -> [Record] {
//        var recordsForWalletInDate = [Record]()
//        for record in getWallet(at: walletIndex).records {
//            if Calendar.current.isDate(record.date, inSameDayAs: date) {
//                recordsForWalletInDate.append(record)
//            }
//        }
//        return recordsForWalletInDate
//    }
//
//    func getAllDatesSorted() -> [Date] {
//        var dates = [Date]()
//        for wallet in wallets {
//            for record in wallet.records {
//                if !dates.contains(where: { date in
//                    Calendar.current.isDate(date, inSameDayAs: record.date)
//                }) {
//                    dates.append(record.date)
//                }
//            }
//        }
//        return dates
//    }
//
//    func getAllDatesSorted(from walletIndex: Int) -> [Date] {
//        var dates = [Date]()
//        let wallet = getWallet(at: walletIndex)
//        for record in wallet.records {
//            if !dates.contains(where: { date in
//                Calendar.current.isDate(date, inSameDayAs: record.date)
//            }) {
//                dates.append(record.date)
//            }
//        }
//        return dates
//    }
//
//    func createFilteredWallet(from walletIndex: Int? = nil, with filterOption: FilterOption = .all) -> Wallet {
//        let allRecords = getRecords(for: walletIndex)
//        let filteredRecords = allRecords.filter { record in
//            switch filterOption {
//            case .all:
//                return true
//            case .expense:
//                return record.isExpense
//            case .income:
//                return !record.isExpense
//            }
//        }
//        var filteredRecordsBalance = 0.0
//        for record in filteredRecords {
//            filteredRecordsBalance += record.amount
//        }
//        var walletName: String {
//            if let walletIndex = walletIndex {
//                return getWallet(at: walletIndex).name
//            }
//            return ""
//        }
//        let wallet = Wallet(name: walletName, balance: filteredRecordsBalance, records: filteredRecords)
//        return wallet
//    }
//
//    func removeRecordFromWallet(recordToRemove: Record) -> Bool {
//        if let index = recordToRemove.wallet.records.firstIndex(of: recordToRemove) {
//            recordToRemove.wallet.records.remove(at: index)
//            return true
////            return recordManager.removeRecord(recordToRemove: recordToRemove)
//        }
//        return false
//    }

}

