//
//  ConfigureWalletCurrencyVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-09-25.
//

import UIKit

class ConfigureWalletCurrencyVC: UIViewController {

    @IBOutlet private weak var chooseCurrencyLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var nextButton: BounceButton!

    private var chosenCurrency: CurrencyType?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        tableView.rowHeight = 50

        nextButton.isEnabled = false

        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        AppCache.shared.chosenCurrency = chosenCurrency
        let addWalletVC = AddWalletVC()
        navigationController?.pushViewController(addWalletVC, animated: true)
    }

    @objc
    private func dismissView() {
        self.dismiss(animated: true)
    }
}

extension ConfigureWalletCurrencyVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CurrencyType.allCases.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)") else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        content.text = CurrencyType.allCases[indexPath.row].getName()
        cell.contentConfiguration = content
        cell.accessoryType = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        nextButton.isEnabled = true
        for index in 0..<tableView.numberOfRows(inSection: indexPath.section) {
            let path = IndexPath(row: index, section: indexPath.section)
            guard let cell = tableView.cellForRow(at: path) else { return }
            cell.accessoryType = (index == indexPath.row) ? .checkmark : .none
        }
        chosenCurrency = CurrencyType.allCases[safe: indexPath.row]
    }
}
