//
//  WalletDetailVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-18.
//

import UIKit
import RealmSwift

class WalletDetailVC: UIViewController {

    private var selectedWalletIndex: Int!
    private let walletManager = WalletManager.shared
    private let recordManager = RecordManager.shared
    private var wallet: Wallet!
    private var filterOption: FilterOption = .all
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noRecordFoundView: UIView!
    @IBOutlet private var balanceView: RoundedView!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var tabBarView: TabBarView!
    @IBOutlet private var circlePlusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard AppCache.shared.chosenWalletIndex != nil else { return }
        selectedWalletIndex = AppCache.shared.chosenWalletIndex

        wallet = walletManager.getWallet(at: selectedWalletIndex)
        title = wallet.name
        
        setupTabBar()
        setupTable()
        refreshScreen()

        let rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.infoImage),
            style: .plain,
            target: self,
            action: #selector(getWalletInfo)
        )
        navigationItem.rightBarButtonItem = rightBarButtonItem

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDeleteWallet),
            name: K.NotificationName.didDeleteWallet,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateWalletName),
            name: K.NotificationName.didUpdateWalletName,
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: K.NotificationName.didUpdateWalletName,
            object: nil
        )
    }

    @IBAction func addRecordTapped(_ sender: Any) {
        walletManager.chosenWalletIndex = selectedWalletIndex
        let addRecordVC = AddRecordVC()
        addRecordVC.delegate = self
        let navigation = UINavigationController(rootViewController: addRecordVC)
        present(navigation, animated: true)
    }
    
    private func setupTabBar() {
        tabBarView.setButtonTitles(buttonTitles: Constants.tabViewButtonTitles)
        tabBarView.setStyle(style: .line)
        tabBarView.setSelectionOrientation(to: .bottom)
        tabBarView.delegate = self
        tabBarView.backgroundColor = .clear
    }
    
    private func refreshScreen() {
        let recordsList = wallet.getRecordsByType(type: filterOption)
        tabBarView.isHidden = filterOption == .all && recordsList.isEmpty
        noRecordFoundView.isHidden = !recordsList.isEmpty
        tableView.isHidden = recordsList.isEmpty
        balanceView.isHidden = recordsList.isEmpty
        circlePlusButton.isHidden = recordsList.isEmpty
        if filterOption == .all {
            balanceLabel.text = LocalizedKeys.balance.localizeWithFormat(arguments: getWalletBalance())
        } else {
            balanceLabel.text = LocalizedKeys.amount.localizeWithFormat(arguments: getTotalAmount())
        }
        tableView.reloadData()
    }
    
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeftRightLabelCell.self, forCellReuseIdentifier: Constants.cellID)
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
        return amount.toCurrencyString(currency: wallet.currency)
    }

    func getTotalAmount() -> String {
        var amount = 0.0
        let records = wallet.getRecordsByType(type: filterOption)
        for record in records {
            amount += record.amount
        }
        return amount.toCurrencyString(currency: wallet.currency)
    }
    
    @objc
    func getWalletInfo() {
        AppCache.shared.chosenWalletIndex = selectedWalletIndex
        let walletInfoVC = WalletInfoVC()
        let navController = UINavigationController(rootViewController: walletInfoVC)
        present(navController, animated: true)
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

    @objc
    private func didDeleteWallet() {
        NotificationCenter.default.removeObserver(
            self,
            name: K.NotificationName.didDeleteWallet,
            object: nil
        )
        navigationController?.popToRootViewController(animated: true)
    }

    @objc
    private func didUpdateWalletName() {
        title = wallet.name
    }

}

// MARK: - TableView
extension WalletDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let selectedWallet = walletManager.getWallet(at: selectedWalletIndex)
        return selectedWallet.getAllDates(filtered: filterOption).count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        let selectedWallet = walletManager.getWallet(at: selectedWalletIndex)
        let date = selectedWallet.getAllDates(filtered: filterOption)[section - 1]
        return date.toString(withFormat: .long)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let selectedWallet = walletManager.getWallet(at: selectedWalletIndex)
        let dates = selectedWallet.getAllDates(filtered: filterOption)

        return selectedWallet.getRecordsForDate(date: dates[section - 1], filteredBy: filterOption).filter { record in
            switch self.filterOption {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID, for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        if indexPath.section == 0 {
            if filterOption == .all {
                content.text = LocalizedKeys.total.localizeWithFormat(arguments: getWalletBalance())
            } else {
                content.text = LocalizedKeys.total.localizeWithFormat(arguments: getTotalAmount())
            }
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            return cell
        }
        let selectedWallet = walletManager.getWallet(at: selectedWalletIndex)
        let date = selectedWallet.getAllDates(filtered: filterOption)[indexPath.section - 1]
        let recordsForDate = [Record](selectedWallet.getRecordsForDate(date: date, filteredBy: filterOption).reversed())
        let recordForDate = recordsForDate[indexPath.row]
        content.text = recordForDate.note
        content.secondaryText = recordForDate.amount.toCurrencyString(currency: recordForDate.currency)
        content.secondaryTextProperties.color = recordForDate.isExpense ? .systemRed : .systemBlue
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == numberOfSections(in: tableView) - 1 {
            return Constants.lastSectionFooterHeight
        } else {
            return Constants.normalSectionFooterHeight
        }
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
        filterOption = FilterOption.init(rawValue: index) ?? .all
        refreshScreen()
    }
}

private extension WalletDetailVC {
    enum Constants {
        static let tabViewButtonTitles = [
            LocalizedKeys.all.localized,
            LocalizedKeys.expenses.localized,
            LocalizedKeys.income.localized
        ]
        static let normalSectionFooterHeight: CGFloat = 15.0
        static let lastSectionFooterHeight: CGFloat = 100.0
        static let infoImage = "info.circle.fill"
        static let cellID = "walletDetailCell"
    }

    enum LocalizedKeys {
        static let all = "wallet_detail_tab_all"
        static let expenses = "wallet_detail_tab_expenses"
        static let income = "wallet_detail_tab_income"
        static let total = "wallet_detail_total"
        static let balance = "wallet_detail_balance"
        static let amount = "wallet_detail_amount"
    }
}
