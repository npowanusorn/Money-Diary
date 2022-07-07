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
        balanceLabel.text = getTotalBalance().toCurrencyString()

        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers
        let temp = navigationArray.last
        navigationArray.removeAll()
        navigationArray.append(temp!)
        self.navigationController?.viewControllers = navigationArray
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
            let addWalletVC = AddWalletVC()
            addWalletVC.delegate = self
            let navController = UINavigationController(rootViewController: addWalletVC)
            navController.navigationBar.titleTextAttributes = getAttributedStringDict(fontSize: 15.0, weight: .bold)
            self.present(navController, animated: true)
        }
        let settingsAction = UIAction(title: LocalizedKeys.settings.localized, image: UIImage(systemName: ImageName.settingsImage)) { _ in
            let settingsVC = SettingsVC()
            let back = UIBarButtonItem()
            back.title = ""
            self.navigationItem.backBarButtonItem = back
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
        let divider = UIMenu(title: "", options: .displayInline, children: [addWalletAction])
        
        let menu = UIMenu(title: "", options: .displayInline, children: [divider, settingsAction])
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
        balanceLabel.text = getTotalBalance().toCurrencyString()
    }

    func getDataFromFirestore() async {
        guard let currentUser = currentUser else { return }
        let walletCollection = db.collection(K.FirestoreKeys.CollectionKeys.users).document(currentUser.uid).collection(K.FirestoreKeys.CollectionKeys.wallets)
        do {
            let walletSnapshot = try await walletCollection.getDocuments()
            let walletDocuments = walletSnapshot.documents
            for walletDocument in walletDocuments {
                let walletName = (walletDocument.data()[K.FirestoreKeys.FieldKeys.name] as? String) ?? ""
                let walletBalance = (walletDocument.data()[K.FirestoreKeys.FieldKeys.balance] as? Double) ?? 0.0
                let walletForSnapshot = Wallet(name: walletName, balance: walletBalance)
                let recordCollection = walletCollection.document(walletDocument.documentID).collection(K.FirestoreKeys.CollectionKeys.records)
                let recordSnapshot = try await recordCollection.getDocuments()
                let recordDocuments = recordSnapshot.documents
                for recordDocument in recordDocuments {
                    let amount = (recordDocument.data()[K.FirestoreKeys.FieldKeys.amount] as? Double) ?? 0.0
                    let date = (recordDocument.data()[K.FirestoreKeys.FieldKeys.date] as? Timestamp)?.dateValue() ?? Date()
                    let isExpense = (recordDocument.data()[K.FirestoreKeys.FieldKeys.expense] as? Bool) ?? true
                    let note = (recordDocument.data()[K.FirestoreKeys.FieldKeys.note] as? String) ?? ""
                    let wallet = (recordDocument.data()[K.FirestoreKeys.FieldKeys.wallet] as? Int) ?? 0
                    let record = Record(amount: amount, note: note, date: date, wallet: wallet, isExpense: isExpense)
                    walletForSnapshot.addRecord(newRecord: record)
                }
                walletManager.addWallet(newWallet: walletForSnapshot)
            }
        } catch {
            Log.error("ERROR GETTING DATA FROM FIRESTORE: \(error)")
        }
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
                return cell
            }
            content.text = walletsList[indexPath.row].name
            content.secondaryText = walletsList[indexPath.row].balance.toCurrencyString()
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            var content = cell.defaultContentConfiguration()
            if recordList.count > 4, indexPath.row == 3 {
                content.text = LocalizedKeys.showAll.localized
                cell.contentConfiguration = content
                cell.accessoryType = .disclosureIndicator
            } else if recordList.count == 0 {
                cell.accessoryType = .none
                cell.selectionStyle = .none
                content.text = LocalizedKeys.noRecord.localized
                cell.contentConfiguration = content
            } else {
                cell.accessoryType = .none
                cell.selectionStyle = .none
                content.text = recordList[indexPath.row].note
                content.secondaryText = recordList[indexPath.row].amount.toCurrencyString()
                content.secondaryTextProperties.color = recordList[indexPath.row].isExpense ? .systemRed : .systemBlue
                cell.contentConfiguration = content
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard walletsList.count > 0 else { return }
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
                let recordForWallet = walletToRemove.records
                do {
                    let realm = try Realm()
                    try realm.write {
//                        Log.info("**** DELETING RECORDS ****")
//                        realm.delete(recordForWallet)
                        Log.info("**** DELETING WALLET ****")
                        realm.delete(walletToRemove)
                        Log.info("**** DELETING DONE ****")
                    }
                } catch {
                    Log.error("ERROR DELETING FROM REALM: \(error)")
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

extension DashboardVC: AddedWalletDelegate {
    func didAddWallet(wallet: Wallet) {
        SPIndicator.present(title: LocalizedKeys.added.localized, preset: .done, haptic: .success)
        walletsList = walletManager.getWallets()
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
