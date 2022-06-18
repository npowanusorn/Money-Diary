//
//  WalletsListVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 17/06/2022.
//

import UIKit

class WalletsListVC: UIViewController {

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "List"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 12
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "walletListCell")
    }

}

extension WalletsListVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WalletManager.shared.numberOfWallets
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletListCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = WalletManager.shared.getWallets(at: indexPath.row).name
        cell.contentConfiguration = content
        if indexPath.row == WalletManager.shared.chosenWalletIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        WalletManager.shared.chosenWalletIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popToRootViewController(animated: true)
    }
}
