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
        WalletType.allCases.count - 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)") else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        content.text = WalletType.allCases[indexPath.section].getName()
        content.textProperties.alignment = .center
        content.textProperties.font = .systemFont(ofSize: 17, weight: .bold)
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        Log.info("SELECTED TYPE: \(indexPath.section)")

        var cellSection = [Int]()
        for index in 0...WalletType.allCases.count {
            if index != indexPath.section {
                cellSection.append(index)
            }
        }
        for section in cellSection {
            let path = IndexPath(row: 0, section: section)
            let cell = tableView.cellForRow(at: path)
            cell?.layer.borderWidth = 0
            cell?.layer.borderColor = nil
        }

        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.layer.borderWidth = 2
        selectedCell?.layer.borderColor = globalTintColor.cgColor
        nextButton.isEnabled = true

        selectedType = WalletType.allCases[indexPath.section]
    }
}
