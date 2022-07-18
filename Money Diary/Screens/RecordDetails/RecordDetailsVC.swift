//
//  RecordDetailsVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 21/06/2022.
//

import UIKit
import SPIndicator

class RecordDetailsVC: UIViewController {

    var selectedRecord: Record!

    @IBOutlet private var tableView: UITableView!

    private let walletManager = WalletManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard selectedRecord != nil else { return }

        setupTable()

        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editRecord))
        rightBarButtonItem.tintColor = globalTintColor
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @IBAction func deleteTapped(_ sender: Any) {
        let alert = UIAlertController.showDeleteConfirmationAlert(with: "Delete record", message: "This action cannot be undone") {
            self.performDeletion()
        }
        present(alert, animated: true)
    }

    @objc func editRecord() {

    }

    func performDeletion() {
        let wallet = walletManager.getWallet(by: selectedRecord.walletID)
        if let wallet = wallet, wallet.removeRecord(recordToRemove: selectedRecord) {
            Task { await FirestoreManager.deleteRecord(record: selectedRecord) }
            navigationController?.popViewController(animated: true)
            SPIndicator.present(title: "Success", message: "Record removed", preset: .done, haptic: .success, from: .top, completion: nil)
        } else {
            let alert = UIAlertController.showDismissAlert(with: "Error", message: "Error deleting record")
            present(alert, animated: true)
        }
    }
    
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
    }

}

extension RecordDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        RecordDetailsTableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        20.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let currentSection = RecordDetailsTableSection(rawValue: section) else { return nil }
        return currentSection.getSectionName()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)") else { return UITableViewCell() }
        guard let currentSection = RecordDetailsTableSection(rawValue: indexPath.section) else { return cell }
        var content = cell.defaultContentConfiguration()
        switch currentSection {
        case .amount:
            content.text = selectedRecord.amount.toCurrencyString()
            content.textProperties.font = UIFont.systemFont(ofSize: 48.0, weight: .bold)
            content.textProperties.color = selectedRecord.isExpense ? .systemRed : .systemBlue
            content.textProperties.alignment = .center
            cell.backgroundColor = .clear
        case .category:
            content.text = "Groceries"
            content.textProperties.font = .systemFont(ofSize: 20.0)
        case .note:
            content.text = selectedRecord.note ?? "N/A"
            content.textProperties.font = .systemFont(ofSize: 20.0)
        case .date:
            content.text = selectedRecord.date.toString(withFormat: .long)
            content.textProperties.font = .systemFont(ofSize: 20.0)
        case .wallet:
            content.text = walletManager.getWallet(by: selectedRecord.walletID)?.name ?? ""
            content.textProperties.font = .systemFont(ofSize: 20.0)
        }
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
}

private enum RecordDetailsTableSection: Int, CaseIterable {
    case amount = 0, category, note, date, wallet
    
    func getName() -> String {
        switch self {
        case .amount:
            return "Amount"
        case .category:
            return "Category"
        case .note:
            return "Note"
        case .date:
            return "Date"
        case .wallet:
            return "Wallet"
        }
    }
    
    func getSectionName() -> String? {
        switch self {
        case .amount:
            return nil
        case .category:
            return "Category"
        case .note:
            return "Note"
        case .date:
            return "Date"
        case .wallet:
            return "Wallet"
        }
    }
}
