//
//  ChooseWalletTypeVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-09-18.
//

import UIKit

class ChooseWalletTypeVC: UIViewController {

    @IBOutlet private weak var walletTypeTableView: UITableView!
    @IBOutlet private weak var nextButton: BounceButton!

    private var selectedType: WalletType = .unknown

    override func viewDidLoad() {
        super.viewDidLoad()

        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem

        walletTypeTableView.delegate = self
        walletTypeTableView.dataSource = self
        walletTypeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        walletTypeTableView.rowHeight = 50
        walletTypeTableView.isScrollEnabled = false

        nextButton.isEnabled = false
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        let configureCurrencyVC = ConfigureWalletCurrencyVC()
        navigationController?.pushViewController(configureCurrencyVC, animated: true)
        AppCache.shared.walletType = selectedType
    }

    @objc
    private func dismissView() {
        self.dismiss(animated: true)
    }

}

extension ChooseWalletTypeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WalletType.allCases.count - 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)") else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        content.text = WalletType.allCases[indexPath.row].getName()
        cell.contentConfiguration = content
        cell.accessoryType = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        Log.info("SELECTED TYPE: \(indexPath.row)")
        for index in 0..<tableView.numberOfRows(inSection: indexPath.section) {
            let path = IndexPath(row: index, section: indexPath.section)
            guard let cell = tableView.cellForRow(at: path) else { return }
            cell.accessoryType = (index == indexPath.row) ? .checkmark : .none
        }
        nextButton.isEnabled = true
        selectedType = WalletType.allCases[indexPath.row]
    }
}
