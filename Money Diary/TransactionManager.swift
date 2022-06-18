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

    func getTransactions() -> [Transaction] {
        return allTransactions
    }

    func addTransaction(newTransaction: Transaction) {
        let index = newTransaction.walletIndex
        WalletManager.shared.modifyBalance(ofWalletIndex: index, by: newTransaction.amount, operation: .subtract)
        WalletManager.shared.addTransactionToWallet(at: index, transaction: newTransaction)
        allTransactions.append(newTransaction)
        allTransactions.sort { transaction1, transaction2 in
            transaction1.date.compare(transaction2.date) == .orderedAscending
        }
    }
}
