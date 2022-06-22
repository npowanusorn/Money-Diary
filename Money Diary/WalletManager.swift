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

    func addWallet(newWallet: Wallet) {
        wallets.append(newWallet)
    }

    func addMockWallets(count: Int) {
        for counter in 1...count {
            let wallet = Wallet(name: "wallet \(counter)", balance: 1000.0, records: [])
            addWallet(newWallet: wallet)
        }
    }

    func updateBalance(ofWalletIndex index: Int, with balance: Double) {
        wallets[index].balance = balance
    }

    func modifyBalance(ofWalletIndex index: Int, by balance: Double, operation: Operation) {
        switch operation {
        case .add:
            wallets[index].balance += balance
        case .subtract:
            wallets[index].balance -= balance
        }
    }

    func addRecordToWallet(record: Record) {
        wallets[record.walletIndex].records.append(record)
    }
    
    func removeWallet(at index: Int) -> Bool {
        guard numberOfWallets > 0, index < numberOfWallets, index >= 0 else { return false }
        wallets.remove(at: index)
        if chosenWalletIndex > index {
            chosenWalletIndex -= 1
        } else if chosenWalletIndex == index {
            chosenWalletIndex = 0
        }
        return true
    }

    func getRecordsForWallet(walletIndex: Int? = nil) -> [Record] {
        if let walletIndex = walletIndex {
            let wallet = getWallet(at: walletIndex)
            return wallet.records
        } else {
            var records = [Record]()
            for wallet in wallets {
                records += wallet.records
            }
            return records
        }
    }

    func createFilteredWallet(from walletIndex: Int? = nil, with filterOption: FilterOption = .all) -> Wallet {
        let allRecords = getRecordsForWallet(walletIndex: walletIndex)
        let filteredRecords = allRecords.filter { record in
            switch filterOption {
            case .all:
                return true
            case .expense:
                return record.isExpense
            case .income:
                return !record.isExpense
            }
        }
        var filteredRecordsBalance = 0.0
        for record in filteredRecords {
            filteredRecordsBalance += record.amount
        }
        var walletName: String {
            if let walletIndex = walletIndex {
                return getWallet(at: walletIndex).name
            }
            return ""
        }
        let wallet = Wallet(name: walletName, balance: filteredRecordsBalance, records: filteredRecords)
        return wallet
    }

    func removeRecordFromWallet(recordToRemove: Record) -> Bool {
        if let index = wallets[recordToRemove.walletIndex].records.firstIndex(of: recordToRemove) {
            wallets[recordToRemove.walletIndex].records.remove(at: index)
            return true
//            return recordManager.removeRecord(recordToRemove: recordToRemove)
        }
        return false
    }

}

