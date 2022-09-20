//
//  WalletInfoVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-09-19.
//

import UIKit

class WalletInfoVC: UIViewController {

    @IBOutlet private weak var walletInfoTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let rightNavBarButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem = rightNavBarButton
        title = "Info"

        walletInfoTableView.delegate = self
        walletInfoTableView.dataSource = self
        walletInfoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        walletInfoTableView.bounces = false
    }

    @objc
    private func dismissView() {
        self.dismiss(animated: true)
    }
}

extension WalletInfoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)") else { return UITableViewCell() }
        guard let currentSection = WalletInfoTableSection(rawValue: indexPath.section) else { return cell }
        guard let chosenWalletIndex = AppCache.shared.chosenWalletIndex else { return cell }
        let selectedWallet = WalletManager.shared.getWallet(at: chosenWalletIndex)
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
    case name = 0, type, balance, id

    func getSectionName() -> String? {
        switch self {
        case .name:
            return nil
        case .type:
            return "type".localized
        case .balance:
            return "balance".localized
        case .id:
            return "id".localized
        }
    }
}
