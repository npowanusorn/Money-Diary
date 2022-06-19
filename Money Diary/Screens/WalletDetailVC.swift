//
//  WalletDetailVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-18.
//

import UIKit

class WalletDetailVC: UIViewController {

    var selectedWalletIndex: Int!
    var wallet: Wallet!
    private let walletManager = WalletManager.shared
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noTransactionFoundView: UIView!
    @IBOutlet private var balanceView: RoundedView!
    @IBOutlet private var balanceLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.sizeToFit()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wallet = walletManager.getWallet(at: selectedWalletIndex)
        guard wallet != nil else { return }
        title = wallet.name
        
        noTransactionFoundView.isHidden = !wallet.transactions.isEmpty
        tableView.isHidden = wallet.transactions.isEmpty
        balanceView.isHidden = wallet.transactions.isEmpty
        balanceLabel.text = "Balance: \(getWalletBalance())"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeftRightLabelCell.self, forCellReuseIdentifier: "walletDetailCell")
    }

    @IBAction func addTransactionTapped(_ sender: Any) {
        walletManager.chosenWalletIndex = selectedWalletIndex
        let addTransactionVC = AddTransactionsVC()
        addTransactionVC.delegate = self
        let navigation = UINavigationController(rootViewController: addTransactionVC)
        present(navigation, animated: true)
    }
    
    func refreshScreen() {
        noTransactionFoundView.isHidden = !wallet.transactions.isEmpty
        tableView.isHidden = wallet.transactions.isEmpty
        balanceView.isHidden = wallet.transactions.isEmpty
        balanceLabel.text = "Balance: \(getWalletBalance())"
        tableView.reloadData()
    }
    
    func getWalletBalance() -> String {
        var amount = wallet.balance
        for transaction in wallet.transactions {
            amount -= transaction.amount
        }
        return String(format: "$%.2f", amount)
    }
}

// MARK: - TableView
extension WalletDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "All transactions in \(wallet.name)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallet.transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let record = wallet.transactions.count == 1 ? "record" : "records"
        return "\(wallet.transactions.count) \(record) found"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletDetailCell", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        let transaction = wallet.transactions[indexPath.row]
        content.text = transaction.notes
        content.secondaryText = String(format: "$%.2f", transaction.amount)
        
        cell.contentConfiguration = content
        return cell
    }
}

extension WalletDetailVC: AddedTransactionDelegate {
    func didAddTransaction(transaction: Transaction) {
        wallet = walletManager.getWallet(at: selectedWalletIndex)
        refreshScreen()
    }
}
