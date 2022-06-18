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

class WalletManager {

    static let shared = WalletManager()

    private init() { }

    private var wallets = [Wallet(name: "Wallet", balance: 0, transactions: [])]

    var chosenWalletIndex = 0

    var numberOfWallets: Int {
        return wallets.count
    }

    func getWallets() -> [Wallet] {
        return wallets
    }

    func getWallets(at index: Int) -> Wallet {
        return wallets[index]
    }

    func addWallet(newWallet: Wallet) {
        wallets.append(newWallet)
    }

    func injectMockWallets(count: Int) {
        for counter in 1...count {
            let wallet = Wallet(name: "wallet \(counter)", balance: Double.random(in: 0...1000), transactions: [])
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

    func addTransactionToWallet(at index: Int, transaction: Transaction) {
        wallets[index].transactions.append(transaction)
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

}
