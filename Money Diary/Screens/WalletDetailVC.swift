//
//  WalletDetailVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-18.
//

import UIKit

class WalletDetailVC: UIViewController {

    var selectedWalletIndex: Int!
    
    private var wallet: Wallet!
    private let walletManager = WalletManager.shared
    private let recordManager = RecordManager.shared
    private let tabViewButtonTitles = ["All", "Expenses", "Income"]
    private var filterOption: FilterOption = .all
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noRecordFoundView: UIView!
    @IBOutlet private var balanceView: RoundedView!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var tabBarView: TabBarView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard selectedWalletIndex != nil else { return }

        tabBarView.setButtonTitles(buttonTitles: tabViewButtonTitles)
        tabBarView.setStyle(style: .line)
        tabBarView.setSelectionOrientation(to: .top)
        tabBarView.delegate = self
        tabBarView.backgroundColor = .clear

        wallet = walletManager.createFilteredWallet(from: selectedWalletIndex, with: .all)
        title = wallet.name

        noRecordFoundView.isHidden = !wallet.records.isEmpty
        tableView.isHidden = wallet.records.isEmpty
        balanceView.isHidden = wallet.records.isEmpty
        balanceLabel.text = "Balance: \(getWalletBalance())"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeftRightLabelCell.self, forCellReuseIdentifier: "walletDetailCell")
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle.fill"), style: .plain, target: self, action: #selector(getWalletInfo))
        navigationItem.rightBarButtonItem = rightBarButtonItem

//        let navBarAppearance = UINavigationBarAppearance()
//        navBarAppearance.configureWithOpaqueBackground()
//        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
//        navigationController?.navigationBar.standardAppearance = navBarAppearance
//        navigationController?.navigationBar.compactAppearance = navBarAppearance
    }

    @IBAction func addRecordTapped(_ sender: Any) {
        walletManager.chosenWalletIndex = selectedWalletIndex
        let addRecordVC = AddRecordVC()
        addRecordVC.delegate = self
        let navigation = UINavigationController(rootViewController: addRecordVC)
        present(navigation, animated: true)
    }
    
    func refreshScreen() {
        noRecordFoundView.isHidden = !wallet.records.isEmpty
        tableView.isHidden = wallet.records.isEmpty
        balanceView.isHidden = wallet.records.isEmpty
        if case .all = filterOption {
            balanceLabel.text = "Balance: \(getWalletBalance())"
        } else {
            balanceLabel.text = "Amount: \(getTotalAmount())"
        }
        tableView.reloadData()
    }
    
    func getWalletBalance() -> String {
        var amount = 0.0
        for record in wallet.records {
            if record.isExpense {
                amount -= record.amount
            } else {
                amount += record.amount
            }
        }
        return amount.toCurrencyString()
    }

    func getTotalAmount() -> String {
        return wallet.balance.toCurrencyString()
    }
    
    @objc
    func getWalletInfo() {
        Log.info("info")
    }

}

// MARK: - TableView
extension WalletDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recordManager.getAllDatesSorted(for: wallet).count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        let date = recordManager.getAllDatesSorted(for: wallet)[section - 1]
        return date.toString(withFormat: .long)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let dates = recordManager.getAllDatesSorted(for: wallet)
        return recordManager.getAllRecords(for: dates[section - 1], in: wallet).filter({ record in
            switch filterOption {
            case .all :
                return true
            case .expense:
                return record.isExpense
            case .income:
                return !record.isExpense
            }
        }).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletDetailCell", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        if indexPath.section == 0 {
            if case .all = filterOption {
                content.text = "Total: \(getWalletBalance())"
            } else {
                content.text = "Total: \(getTotalAmount())"
            }
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            return cell
        }
        let dates = recordManager.getAllDatesSorted(for: wallet)
        let record = recordManager.getAllRecords(for: dates[indexPath.section - 1], in: wallet)[indexPath.row]
        content.text = record.notes
        content.secondaryText = record.amount.toCurrencyString()
        content.secondaryTextProperties.color = record.isExpense ? .systemRed : .systemBlue
        
        cell.contentConfiguration = content
        return cell
    }
}

extension WalletDetailVC: AddedRecordDelegate {
    func didAddRecord(record: Record) {
        wallet = walletManager.getWallet(at: selectedWalletIndex)
        refreshScreen()
    }
}

extension WalletDetailVC: TabBarViewDelegate {
    func didChangeToIndex(index: Int) {
        Log.info("did change to idx: \(index) for walletindex: \(selectedWalletIndex ?? -1)")

        if index == 0 {
            wallet = walletManager.createFilteredWallet(from: selectedWalletIndex, with: .all)
            filterOption = .all
        } else if index == 1 {
            wallet = walletManager.createFilteredWallet(from: selectedWalletIndex, with: .expense)
            filterOption = .expense
        } else {
            wallet = walletManager.createFilteredWallet(from: selectedWalletIndex, with: .income)
            filterOption = .income
        }
        refreshScreen()
    }
}
