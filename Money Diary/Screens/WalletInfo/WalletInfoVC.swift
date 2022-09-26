//
//  WalletInfoVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-09-19.
//

import UIKit

class WalletInfoVC: UIViewController {

    @IBOutlet private weak var deleteButton: BounceButton!
    @IBOutlet private weak var walletInfoTableView: UITableView!

    private var chosenWalletIndex: Int {
        guard let index = AppCache.shared.chosenWalletIndex else {
            fatalError()
        }
        return index
    }

    private var selectedWallet: Wallet {
        WalletManager.shared.getWallet(at: chosenWalletIndex)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let dismissNavBarButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(leftNavBarButtonTapped))
        let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(rightNavBarButtonTapped))
        navigationItem.leftBarButtonItem = dismissNavBarButton
        navigationItem.rightBarButtonItem = editNavBarButton
        title = LocalizedKeys.title.localized

        walletInfoTableView.delegate = self
        walletInfoTableView.dataSource = self
        walletInfoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        walletInfoTableView.bounces = false
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alert = UIAlertController.showDeleteConfirmationAlert(
            with: LocalizedKeys.alertTitle.localized,
            message: LocalizedKeys.alertMessage.localized
        ) {
            self.handleDeleteWallet()
        }
        present(alert, animated: true)
    }

    @objc
    private func leftNavBarButtonTapped() {
        self.dismiss(animated: true)
    }

    @objc
    private func rightNavBarButtonTapped() {
        Log.info("EDIT WALLET TAPPED GO TO EDIT WALLET VC")
    }

    private func handleDeleteWallet() {
        Task {
            await FirestoreManager.deleteWallet(wallet: selectedWallet)
            if WalletManager.shared.removeWallet(at: chosenWalletIndex) {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: Notification.Name(K.NotificationName.didDeleteWallet), object: nil)
                }
            }
        }
    }
}

extension WalletInfoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)") else { return UITableViewCell() }
        guard let currentSection = WalletInfoTableSection(rawValue: indexPath.section) else { return cell }
        var content = cell.defaultContentConfiguration()
        switch currentSection {
        case .name:
            content.text = selectedWallet.name
            content.textProperties.font = .systemFont(ofSize: 48, weight: .bold)
            content.textProperties.alignment = .center
            cell.backgroundColor = .clear
        case .type:
            content.text = selectedWallet.type.getName()
        case .balance:
            content.text = selectedWallet.balance.toCurrencyString()
        case .dateCreated:
            content.text = selectedWallet.dateCreated.formatted()
        case .id:
            content.text = selectedWallet.id
            content.textProperties.font = .systemFont(ofSize: 12)
        }
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        WalletInfoTableSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let currentSection = WalletInfoTableSection(rawValue: section) else { return nil }
        return currentSection.getSectionName()
    }
}

private enum WalletInfoTableSection: Int, CaseIterable {
    case name = 0, type, balance, dateCreated, id

    func getSectionName() -> String? {
        switch self {
        case .name:
            return nil
        case .type:
            return LocalizedKeys.type.localized
        case .balance:
            return LocalizedKeys.balance.localized
        case .dateCreated:
            return LocalizedKeys.dateCreated.localized
        case .id:
            return LocalizedKeys.id.localized
        }
    }
}

private enum LocalizedKeys {
    static let title = "title"
    static let alertTitle = "alert_title"
    static let alertMessage = "alert_message"
    static let type = "type"
    static let balance = "balance"
    static let id = "id"
    static let dateCreated = "date_created"
}
