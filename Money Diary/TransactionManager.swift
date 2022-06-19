//
//  TransactionManager.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import Foundation

class TransactionManager {

    static let shared = TransactionManager()

    private init() { }

    private var allTransactions = [Transaction]()
    private let walletManager = WalletManager.shared

    func getAllTransactions() -> [Transaction] {
        return allTransactions
    }

    func addTransaction(newTransaction: Transaction) {
        let index = newTransaction.walletIndex
        walletManager.modifyBalance(ofWalletIndex: index, by: newTransaction.amount, operation: .subtract)
        walletManager.addTransactionToWallet(transaction: newTransaction)
        allTransactions.append(newTransaction)
        allTransactions.sort { transaction1, transaction2 in
            transaction1.date.compare(transaction2.date) == .orderedDescending
        }
    }
    
    func getAllTransactions(for walletIndex: Int) -> [Transaction] {
        var list = [Transaction]()
        for transaction in allTransactions {
            if transaction.walletIndex == walletIndex {
                list.append(transaction)
            }
        }
        return list
    }
    
    func getRecord(from walletIndex: Int, with name: String) -> Transaction? {
        let list = walletManager.getWallet(at: walletIndex).transactions
        for item in list {
            if item.notes == name {
                return item
            }
        }
        return nil
    }
    
    func addMockTransactions(count: Int, walletIndex: Int) {
        for counter in 1...count {
            let transaction = Transaction(amount: Double.random(in: 1...100), notes: "tr \(counter)", date: Date(), walletIndex: walletIndex)
            addTransaction(newTransaction: transaction)
        }
    }
    
    func searchForTransaction(by name: String) -> [Transaction] {
        var list = [Transaction]()
        for transaction in allTransactions {
            if transaction.notes.contains(name) {
                list.append(transaction)
            }
        }
        return list
    }
}
