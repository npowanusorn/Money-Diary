//
//  DashboardVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import UIKit
import SPIndicator

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
        WalletManager.shared.addMockWallets(count: 5)
        for index in 1...5 {
            TransactionManager.shared.addMockTransactions(count: Int.random(in: 1...5), walletIndex: index)
        }
        walletsList = WalletManager.shared.getWallets()
        transactionList = TransactionManager.shared.getAllTransactions()
        balanceLabel.text = String(format: "$%.2f", getTotalBalance())
        setupMenuButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        let divider = UIMenu(title: "", options: .displayInline, children: [addWalletAction])
        
        let menu = UIMenu(title: "", options: .displayInline, children: [divider, settingsAction])
        ellipsisButton.menu = menu
        ellipsisButton.showsMenuAsPrimaryAction = true
    }
    
    func getTotalBalance() -> Double {
        var amount: Double = 0
        for wallet in WalletManager.shared.getWallets() {
            amount += wallet.balance
        }
        return amount
    }

    func refreshData(at indexPath: IndexPath? = nil) {
        walletsList = WalletManager.shared.getWallets()
        transactionList = TransactionManager.shared.getAllTransactions()
//        if let indexPath = indexPath {
//            tableView.reloadRows(at: [indexPath], with: .fade)
//        } else {
//        }
        tableView.reloadData()
        balanceLabel.text = String(format: "$%.2f", getTotalBalance())
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
            var content = cell.defaultContentConfiguration()
            content.textProperties.font = UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
            if transactionList.count > 4, indexPath.row == 3 {
                content.text = "Show all"
                cell.contentConfiguration = content
                cell.accessoryType = .disclosureIndicator
            } else if transactionList.count == 0 {
                cell.selectionStyle = .none
                content.text = "No recent transactions"
                cell.contentConfiguration = content
            } else {
                cell.selectionStyle = .none
                content.text = transactionList[indexPath.row].notes
                content.secondaryText = String(format: "$%.2f", transactionList[indexPath.row].amount)
                cell.contentConfiguration = content
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let walletDetailVC = WalletDetailVC()
            walletDetailVC.selectedWalletIndex = indexPath.row
            let back = UIBarButtonItem()
            back.title = ""
            navigationItem.backBarButtonItem = back
            navigationController?.pushViewController(walletDetailVC, animated: true)
        } else if indexPath.section == 1, indexPath.row == 3 {
            let allRecordsVC = AllRecordsVC()
            let back = UIBarButtonItem()
            back.title = ""
            navigationItem.backBarButtonItem = back
            navigationController?.pushViewController(allRecordsVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 { return nil }
        if WalletManager.shared.numberOfWallets == 0 { return nil }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            let alertController = UIAlertController(title: "Delete Wallet", message: "Delete wallet?", preferredStyle: .alert)
            let deleteAlertAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                let result = WalletManager.shared.removeWallet(at: indexPath.row)
                self.refreshData(at: indexPath)
                completion(result)
            }
            let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(false)
            }
            alertController.addAction(deleteAlertAction)
            alertController.addAction(cancelAlertAction)
            self.present(alertController, animated: true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension DashboardVC: AddedTransactionDelegate {
    func didAddTransaction(transaction: Transaction) {
        SPIndicator.present(title: "Added", preset: .done, haptic: .success)
        walletsList = WalletManager.shared.getWallets()
        transactionList = TransactionManager.shared.getAllTransactions()
        refreshData()
    }
}

extension DashboardVC: AddedWalletDelegate {
    func didAddWallet(wallet: Wallet) {
        SPIndicator.present(title: "Added", preset: .done, haptic: .success)
        walletsList = WalletManager.shared.getWallets()
        refreshData()
    }
}
