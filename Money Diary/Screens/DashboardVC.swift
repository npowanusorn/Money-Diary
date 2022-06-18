//
//  DashboardVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import UIKit

class DashboardVC: UIViewController {

    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var ellipsisButton: UIButton!

    var transactionList: [Transaction] = [Transaction]()
    var walletsList: [Wallet] = [Wallet]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 12

//        transactionList = [Transaction(amount: 1, notes: "a", date: Date()), Transaction(amount: 2, notes: "b", date: Date())]
        WalletManager.shared.injectMockWallets(count: 10)
        walletsList = WalletManager.shared.getWallets()
        transactionList = TransactionManager.shared.getTransactions()
        balanceLabel.text = String(format: "$%.2f", getTotalBalance())
        setupMenuButton()
    }

    @IBAction func addTransactionTapped(_ sender: Any) {
        let addTransactionVC = AddTransactionsVC()
        addTransactionVC.delegate = self
        let navigation = UINavigationController(rootViewController: addTransactionVC)
        present(navigation, animated: true)
    }

    func setupMenuButton() {
        let addWalletAction = UIAction(title: "Add Wallet", image: UIImage(systemName: "plus")) { _ in
            let addWalletVC = AddWalletVC()
            addWalletVC.delegate = self
            let navController = UINavigationController(rootViewController: addWalletVC)
            self.present(navController, animated: true)
        }
        let settingsAction = UIAction(title: "Settings", image: UIImage(systemName: "gear")) { _ in
            print("settings")
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [addWalletAction, settingsAction])
        ellipsisButton.menu = menu
        ellipsisButton.showsMenuAsPrimaryAction = true

    }

}

// MARK: - TableViews
extension DashboardVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Wallets"
        } else {
            return "Recent Transactions"
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return walletsList.count == 0 ? 1 : walletsList.count
        } else {
            if transactionList.count == 0 {
                return 1
            } else if transactionList.count > 4 {
                return 4
            } else {
                return transactionList.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            var content = cell.defaultContentConfiguration()
            content.textProperties.font = UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
            if walletsList.count == 0 {
                content.text = "No wallets"
                cell.contentConfiguration = content
                cell.selectionStyle = .none
                return cell
            }
            content.text = walletsList[indexPath.row].name
            content.secondaryText = String(format: "$%.2f", walletsList[indexPath.row].balance)
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "recentTransactionCell")
            cell.selectionStyle = .none
            var content = cell.defaultContentConfiguration()
            content.textProperties.font = UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
            if transactionList.count == 0 {
                content.text = "No recent transactions"
                cell.contentConfiguration = content
                return cell
            }
            content.text = transactionList[indexPath.row].notes
            content.secondaryText = String(format: "$%.2f", transactionList[indexPath.row].amount)
            cell.contentConfiguration = content
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func getTotalBalance() -> Double {
        var amount: Double = 0
        for wallet in WalletManager.shared.getWallets() {
            amount += wallet.balance
        }
        return amount
    }

    func refreshData() {
        tableView.reloadData()
        balanceLabel.text = String(format: "$%.2f", getTotalBalance())
    }
}

extension DashboardVC: AddedTransactionDelegate {
    func didAddTransaction(transaction: Transaction) {
        TransactionManager.shared.addTransaction(newTransaction: transaction)
        walletsList = WalletManager.shared.getWallets()
        transactionList = TransactionManager.shared.getTransactions()
        refreshData()
    }
}

extension DashboardVC: AddedWalletDelegate {
    func didAddWallet(wallet: Wallet) {
        walletsList = WalletManager.shared.getWallets()
        refreshData()
    }
}
