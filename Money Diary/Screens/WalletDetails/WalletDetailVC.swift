//
//  WalletDetailVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-18.
//

import UIKit

class WalletDetailVC: UIViewController {

    var selectedWalletIndex: Int!
    
    private let walletManager = WalletManager.shared
    private let recordManager = RecordManager.shared
    private var wallet: Wallet!
    private var filteredRecord = [Record]()
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

        wallet = walletManager.getWallet(at: selectedWalletIndex)
        filteredRecord = wallet.records
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
        var amount = 0.0
        for record in filteredRecord {
            amount += record.amount
        }
        return amount.toCurrencyString()
    }
    
    @objc
    func getWalletInfo() {
        Log.info("info")
    }

    func getAllDates(from records: [Record]) -> [Date] {
        var dates = [Date]()
        for record in records {
            if !dates.contains(where: { date in
                Calendar.current.isDate(date, inSameDayAs: record.date)
            }) {
                dates.append(record.date)
            }
        }
        return dates
    }

}

// MARK: - TableView
extension WalletDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let selectedWallet = walletManager.getWallet(at: selectedWalletIndex)
        return selectedWallet.getAllDates().count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        let selectedWallet = walletManager.getWallet(at: selectedWalletIndex)
        let date = selectedWallet.getAllDates()[section - 1]
        return date.toString(withFormat: .long)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let selectedWallet = walletManager.getWallet(at: selectedWalletIndex)
        let dates = selectedWallet.getAllDates()

        return selectedWallet.getRecordsForDate(date: dates[section - 1]).filter { record in
            switch filterOption {
            case .all:
                return true
            case .expense:
                return record.isExpense
            case .income:
                return !record.isExpense
            }
        }.count
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
        let record = filteredRecord[indexPath.row]
        content.text = record.note
        content.secondaryText = record.amount.toCurrencyString()
        content.secondaryTextProperties.color = record.isExpense ? .systemRed : .systemBlue
        
        cell.contentConfiguration = content
        return cell
    }
}

extension WalletDetailVC: AddedRecordDelegate {
    func didAddRecord(record: Record) {
        wallet = walletManager.getWallet(at: selectedWalletIndex)
        filteredRecord = wallet.records
        refreshScreen()
    }
}

extension WalletDetailVC: TabBarViewDelegate {
    func didChangeToIndex(index: Int) {

        let selectedWallet = walletManager.getWallet(at: selectedWalletIndex)
        if index == 0 {
            filteredRecord = selectedWallet.getRecordsByType(type: .all)
            filterOption = .all
        } else if index == 1 {
            filteredRecord = selectedWallet.getRecordsByType(type: .expense)
            filterOption = .expense
        } else {
            filteredRecord = selectedWallet.getRecordsByType(type: .income)
            filterOption = .income
        }
        refreshScreen()
    }
}
