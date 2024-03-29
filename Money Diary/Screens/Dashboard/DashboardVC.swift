//
//  DashboardVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import UIKit
import SPIndicator
import Firebase
import RealmSwift

class DashboardVC: UIViewController {

    @IBOutlet private var addRecordButton: BounceButton!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var ellipsisButton: UIButton!

    private let walletManager = WalletManager.shared
    private let recordManager = RecordManager.shared
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser

    var recordList: [Record] = [Record]()
    var walletsList: [Wallet] = [Wallet]()

    override func viewDidLoad() {
        super.viewDidLoad()

        Log.info("ISLOGGEDIN: \(Auth.auth().currentUser != nil)")

        UserDefaults.standard.set(true, forKey: K.UserDefaultsKeys.isLoggedIn)

        setupMenuButton()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 12
        tableView.register(LeftRightLabelCell.self, forCellReuseIdentifier: "\(LeftRightLabelCell.self)")

        walletsList = walletManager.getWallets()
        recordList = recordManager.getAllRecords()
        // TODO: Add currency support
        balanceLabel.text = getTotalBalance().toCurrencyString(currency: .CAD)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAddWallet),
            name: K.NotificationName.didAddWallet,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)


        ellipsisButton.tintColor = globalTintColor
        addRecordButton.configuration?.baseBackgroundColor = globalTintColor

        refreshData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func addRecordTapped(_ sender: Any) {
        guard !walletsList.isEmpty else {
            let alert = UIAlertController.showDismissAlert(with: LocalizedKeys.noWallet.localized, message: LocalizedKeys.noWalletMessage.localized)
            present(alert, animated: true)
            return
        }
        let addRecordVC = AddRecordVC()
        addRecordVC.delegate = self
        let navigation = UINavigationController(rootViewController: addRecordVC)
        present(navigation, animated: true)
    }

    func setupMenuButton() {
        let addWalletAction = UIAction(title: LocalizedKeys.addWallet.localized, image: UIImage(systemName: ImageName.addImage)) { _ in
            let chooseWalletType = ChooseWalletTypeVC()
            let navController = UINavigationController(rootViewController: chooseWalletType)
            navController.navigationBar.titleTextAttributes = getAttributedStringDict(fontSize: 15.0, weight: .bold)
            self.present(navController, animated: true)
        }
        let menu = UIMenu(title: "", options: .displayInline, children: [addWalletAction])
        ellipsisButton.menu = menu
        ellipsisButton.showsMenuAsPrimaryAction = true

    }
    
    func getTotalBalance() -> Double {
        var amount: Double = 0
        for wallet in walletManager.getWallets() {
            amount += wallet.balance
        }
        return amount
    }

    func refreshData() {
        walletsList = walletManager.getWallets()
        recordList = recordManager.getAllRecords()
        tableView.reloadData()
        // TODO: Add currency support
        balanceLabel.text = getTotalBalance().toCurrencyString(currency: .CAD)
    }

    @objc
    func didAddWallet() {
        SPIndicator.present(title: LocalizedKeys.added.localized, preset: .done, haptic: .success)
        walletsList = walletManager.getWallets()
        refreshData()
    }

    private func getNumberOfRows(forSection section: Int) -> Int {
        if section == DashboardTableSections.myWallet.rawValue {
            return walletsList.count == 0 ? 1 : walletsList.count
        } else {
            if recordList.count == 0 {
                return 1
            } else if recordList.count > 4 {
                return 4
            } else {
                return recordList.count
            }
        }
    }
    
    private func deleteWalletFromRealm(wallet: Wallet) {
        do {
            let realm = try Realm()
            try realm.write {
//                Log.info("**** DELETING RECORDS ****")
//                realm.delete(recordForWallet)
                Log.info("**** DELETING WALLET ****")
                realm.delete(wallet)
                Log.info("**** DELETING DONE ****")
            }
        } catch {
            Log.error("ERROR DELETING FROM REALM: \(error)")
        }
    }

}

// MARK: - TableViews
extension DashboardVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DashboardTableSections.allCases[section].name()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return DashboardTableSections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumberOfRows(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(LeftRightLabelCell.self)",
            for: indexPath
        ) as? LeftRightLabelCell else {
            return UITableViewCell()
        }
        
        if indexPath.section == DashboardTableSections.myWallet.rawValue {
            cell.selectionStyle = .default
            var content = cell.defaultContentConfiguration()
            if walletsList.count == 0 {
                content.text = LocalizedKeys.noWallet.localized
                cell.contentConfiguration = content
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
                return cell
            }
            let currentWallet = walletsList[indexPath.row]
            content.text = currentWallet.name
            content.secondaryText = walletsList[indexPath.row].balance.toCurrencyString(currency: currentWallet.currency)
            Log.info("CURRENCY: \(currentWallet.currency)")
            cell.contentConfiguration = content
        } else {
            var content = cell.defaultContentConfiguration()
            if recordList.count > 4, indexPath.row == 3 {
                content.text = LocalizedKeys.showAll.localized
                cell.contentConfiguration = content
            } else if recordList.count == 0 {
                cell.accessoryType = .none
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
                content.text = LocalizedKeys.noRecord.localized
                cell.contentConfiguration = content
                return cell
            } else {
                let currentRecordForRow = recordList[indexPath.row]
                content.text = currentRecordForRow.note
                content.secondaryText = currentRecordForRow.amount.toCurrencyString(currency: currentRecordForRow.currency)
                content.secondaryTextProperties.color = currentRecordForRow.isExpense ? .systemRed : .systemBlue
                cell.contentConfiguration = content
            }
        }
        cell.accessoryType = .disclosureIndicator
        cell.isUserInteractionEnabled = true
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == DashboardTableSections.myWallet.rawValue {
            guard walletsList.count > 0 else { return }
            AppCache.shared.chosenWalletIndex = indexPath.row
            let walletDetailVC = WalletDetailVC()
            let back = UIBarButtonItem()
            back.title = LocalizedKeys.home.localized
            navigationItem.backBarButtonItem = back
            navigationController?.pushViewController(walletDetailVC, animated: true)
        } else if indexPath.section == DashboardTableSections.recentRecord.rawValue, indexPath.row == 3, recordList.count > 4 {
            let allRecordsVC = AllRecordsVC()
            let back = UIBarButtonItem()
            back.title = LocalizedKeys.home.localized
            navigationItem.backBarButtonItem = back
            navigationController?.pushViewController(allRecordsVC, animated: true)
        } else {
            AppCache.shared.selectedRecord = recordList[indexPath.row]
            let recordDetailVC = RecordDetailsVC()
            let back = UIBarButtonItem()
            back.title = LocalizedKeys.home.localized
            navigationItem.backBarButtonItem = back
            navigationController?.pushViewController(recordDetailVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 { return nil }
        if walletManager.numberOfWallets == 0 { return nil }
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: LocalizedKeys.deleteAction.localized
        ) { action, view, completion in
            let alert = UIAlertController.showDeleteConfirmationAlert(
                with: LocalizedKeys.deleteTitle.localized,
                message: LocalizedKeys.deleteMessage.localized
            ) {
                let walletToRemove = self.walletManager.getWallet(at: indexPath.row)
                if UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.localAccount) {
                    self.deleteWalletFromRealm(wallet: walletToRemove)
                } else {
                    Task { await FirestoreManager.deleteWallet(wallet: walletToRemove) }
                }
                
                let result = self.walletManager.removeWallet(at: indexPath.row)
                self.refreshData()
                completion(result)
            } secondaryCompletion: {
                completion(false)
            }
            self.present(alert, animated: true)
        }
        deleteAction.image = UIImage(systemName: ImageName.deleteImage)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension DashboardVC: AddedRecordDelegate {
    func didAddRecord(record: Record) {
        SPIndicator.present(title: LocalizedKeys.added.localized, preset: .done, haptic: .success)
        walletsList = walletManager.getWallets()
        recordList = recordManager.getAllRecords()
        refreshData()
    }
}

private extension DashboardVC {
    enum LocalizedKeys {
        static let title = "dashboard_title"
        static let totalBalance = "dashboard_total_balance"
        static let myWallet = "dashboard_my_wallet"
        static let recentRecords = "dashboard_recent_records"
        static let addRecord = "dashboard_add_record"
        static let addWallet = "dashboard_menu_add_wallet"
        static let settings = "dashboard_menu_settings"
        static let noWallet = "dashboard_no_wallet"
        static let noRecord = "dashboard_no_record"
        static let showAll = "dashboard_show_all"
        static let deleteTitle = "dashboard_alert_delete_title"
        static let deleteMessage = "dashboard_alert_delete_message"
        static let cancel = "dashboard_alert_cancel"
        static let deleteAction = "dashboard_alert_delete"
        static let added = "dashboard_indicator_added"
        static let noWalletMessage = "dashboard_alert_no_wallet_message"
        static let home = "dashboard_back_home"
    }
    enum ImageName {
        static let ellipsisImage = "ellipsis.circle.fill"
        static let settingsImage = "gear"
        static let addImage = "plus"
        static let deleteImage = "trash.fill"
    }
    enum DashboardTableSections: Int, CaseIterable {
        case myWallet = 0
        case recentRecord

        func name() -> String {
            switch self {
            case .myWallet:
                return LocalizedKeys.myWallet.localized
            case .recentRecord:
                return LocalizedKeys.recentRecords.localized
            }
        }
    }
}
