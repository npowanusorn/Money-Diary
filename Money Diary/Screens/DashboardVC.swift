//
//  DashboardVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import UIKit
import SPIndicator

class DashboardVC: UIViewController {

    @IBOutlet private var addRecordButton: UIButton!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var ellipsisButton: UIButton!

    private let walletManager = WalletManager.shared
    private let recordManager = RecordManager.shared

    var recordList: [Record] = [Record]()
    var walletsList: [Wallet] = [Wallet]()

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "ellipsis.circle.fill"), style: .plain, target: nil, action: nil)
//        navigationItem.setTitleAndSubtitle(title: getTotalBalance().toCurrencyString(), subtitle: "Total balance")
//        navigationController?.navigationBar.prefersLargeTitles = true
//        ellipsisButton.isHidden = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 12

        walletManager.addMockWallets(count: 5)
        for index in 0...4 {
            walletManager.addMockRecords(count: Int.random(in: 1...5), walletIndex: index)
        }
        walletsList = walletManager.getWallets()
        recordList = recordManager.getAllRecords()
        balanceLabel.text = getTotalBalance().toCurrencyString()
        setupMenuButton()
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
        let addRecordVC = AddRecordVC()
        addRecordVC.delegate = self
        let navigation = UINavigationController(rootViewController: addRecordVC)
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
            let settingsVC = SettingsVC()
            let back = UIBarButtonItem()
            back.title = ""
            self.navigationItem.backBarButtonItem = back
            self.navigationController?.pushViewController(settingsVC, animated: true)
        }
        let divider = UIMenu(title: "", options: .displayInline, children: [addWalletAction])
        
        let menu = UIMenu(title: "", options: .displayInline, children: [divider, settingsAction])
//        navigationItem.rightBarButtonItem?.menu = menu
        ellipsisButton.menu = menu
        ellipsisButton.showsMenuAsPrimaryAction = true

        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 0
        configuration.image = UIImage(systemName: "ellipsis.circle.fill")
        configuration.buttonSize = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

//        ellipsisButton.imageView?.contentMode = .scaleAspectFit
//        ellipsisButton.backgroundColor = .yellow
        ellipsisButton.configuration = configuration
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
        if section == 0 {
            return "My Wallets"
        } else {
            return "Recent Records"
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            var content = cell.defaultContentConfiguration()
            if walletsList.count == 0 {
                content.text = "No wallets"
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
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "recentRecordCell")
            var content = cell.defaultContentConfiguration()
            if recordList.count > 4, indexPath.row == 3 {
                content.text = "Show all"
                cell.contentConfiguration = content
                cell.accessoryType = .disclosureIndicator
            } else if recordList.count == 0 {
                cell.selectionStyle = .none
                content.text = "No recent record"
                cell.contentConfiguration = content
            } else {
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
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            let alert = UIAlertController.showDeleteConfirmationAlert(with: "Delete Wallet", message: "This action cannot be undone") {
                let result = self.walletManager.removeWallet(at: indexPath.row)
                self.refreshData()
                completion(result)
            } secondaryCompletion: {
                completion(false)
            }
            self.present(alert, animated: true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension DashboardVC: AddedRecordDelegate {
    func didAddRecord(record: Record) {
        SPIndicator.present(title: "Added", preset: .done, haptic: .success)
        walletsList = walletManager.getWallets()
        recordList = recordManager.getAllRecords()
        refreshData()
    }
}

extension DashboardVC: AddedWalletDelegate {
    func didAddWallet(wallet: Wallet) {
        SPIndicator.present(title: "Added", preset: .done, haptic: .success)
        walletsList = walletManager.getWallets()
        refreshData()
    }
}
