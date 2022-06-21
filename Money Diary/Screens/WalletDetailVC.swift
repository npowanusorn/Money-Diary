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
    private var filteredRecords = [Record]()
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noRecordFoundView: UIView!
    @IBOutlet private var balanceView: RoundedView!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var tabBarView: TabBarView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarView.setButtonTitles(buttonTitles: tabViewButtonTitles)
        tabBarView.setStyle(style: .line)
        tabBarView.setSelectionOrientation(to: .top)
        tabBarView.delegate = self
        tabBarView.backgroundColor = .clear
        
        wallet = walletManager.getWallet(at: selectedWalletIndex)
        guard wallet != nil else { return }
        title = wallet.name
        filteredRecords = wallet.records
        
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
        balanceLabel.text = "Balance: \(getWalletBalance())"
        tableView.reloadData()
    }
    
    func getWalletBalance() -> String {
        var amount = wallet.balance
        for record in wallet.records {
            amount -= record.amount
        }
        return amount.toCurrencyString()
    }
    
    @objc
    func getWalletInfo() {
        Log.info("info")
    }

    private func filterRecords(option: FilterOption) {
        switch option {
        case .all:
            filterOption = wallet
        case .expense:
            let filtered = wallet.records.filter { record in
                return record.isExpense
            }
            filteredRecords = filtered
        case .income:
            let filtered = wallet.records.filter { record in
                return !record.isExpense
            }
            filteredRecords = filtered
        }
        refreshScreen()
    }
}

// MARK: - TableView
extension WalletDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recordManager.getAllDatesSorted(for: selectedWalletIndex).count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        let date = recordManager.getAllDatesSorted(for: selectedWalletIndex)[section - 1]
        return date.toString(with: .long)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let dates = recordManager.getAllDatesSorted(for: selectedWalletIndex)
        return recordManager.getAllRecords(for: dates[section - 1], in: selectedWalletIndex).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletDetailCell", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
//        content.textProperties.font = K.Fonts.regular.getFont(size: 17)
        if indexPath.section == 0 {
            content.text = "Balance: \(getWalletBalance())"
            content.textProperties.alignment = .center
//            content.textProperties.font = UIFont(name: "Avenir Next Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
            cell.contentConfiguration = content
            return cell
        }
        let dates = recordManager.getAllDatesSorted(for: selectedWalletIndex)
        let record = recordManager.getAllRecords(for: dates[indexPath.section - 1], in: selectedWalletIndex)[indexPath.row]
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
        Log.info("did change to idx: \(index) for walletindex: \(selectedWalletIndex)")

        if index == 0 {
            filterRecords(option: .all)
            filterOption = .all
        } else if index == 1 {
            filterRecords(option: .expense)
            filterOption = .expense
        } else {
            filterRecords(option: .income)
            filterOption = .income
        }
    }
}

private extension WalletDetailVC {
    enum FilterOption {
        case all
        case expense
        case income
    }
}
