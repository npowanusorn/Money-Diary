//
//  AllRecordsVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-18.
//

import UIKit

class AllRecordsVC: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    private let walletManager = WalletManager.shared
    private let recordManager = RecordManager.shared
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(LeftRightLabelCell.self, forCellReuseIdentifier: "allRecordsCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        title = "All records"
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle.fill"), style: .plain, target: self, action: #selector(showSortAlert))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc
    func showSortAlert() {
        let attributedString = NSAttributedString(string: "Sort by", attributes: [
            NSAttributedString.Key.foregroundColor : globalTintColor
        ])
        let alertController = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        alertController.setValue(attributedString, forKey: "attributedTitle")
        let walletAction = UIAlertAction(title: "Wallet", style: .default) { _ in
            self.walletManager.sortBy = .wallet
            self.tableView.reloadData()
        }
        walletAction.setValue(globalTintColor, forKey: "titleTextColor")
        let dateAction = UIAlertAction(title: "Date", style: .default) { _ in
            self.walletManager.sortBy = .date
            self.tableView.reloadData()
        }
        dateAction.setValue(globalTintColor, forKey: "titleTextColor")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(globalTintColor, forKey: "titleTextColor")
        let checkmarkImage = UIImage(systemName: "checkmark") ?? UIImage()
        switch walletManager.sortBy {
        case .wallet:
            walletAction.setValue(checkmarkImage, forKey: "image")
            dateAction.setValue(nil, forKey: "image")
        case .date:
            dateAction.setValue(checkmarkImage, forKey: "image")
            walletAction.setValue(nil, forKey: "image")
        }

        alertController.addActions([walletAction, dateAction, cancelAction])
        present(alertController, animated: true)
    }
    
    func configureCellByWallet(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRecordsCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let wallet = walletManager.getWallet(at: indexPath.section)
        let records = wallet.records
        if records.count == 0 {
            content.text = "No record available"
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            cell.accessoryType = .none
            return cell
        } else {
            let record = records[indexPath.row]
            content.text = record.note
            content.secondaryText = record.amount.toCurrencyString(currency: record.currency)
            content.secondaryTextProperties.color = record.isExpense ? .systemRed : .systemBlue
            cell.contentConfiguration = content
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func configureCellByDate(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRecordsCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let dates = recordManager.getAllDates()
        let record = recordManager.getAllRecords(for: dates[indexPath.section])[indexPath.row]
        content.text = record.note
        content.secondaryText = record.amount.toCurrencyString(currency: record.currency)
        content.secondaryTextProperties.color = record.isExpense ? .systemRed : .systemBlue
        cell.contentConfiguration = content
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        return cell
    }

}

extension AllRecordsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch walletManager.sortBy {
        case .wallet:
            return walletManager.numberOfWallets
        case .date:
            return recordManager.getAllDates().count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch walletManager.sortBy {
        case .wallet:
            let wallet = walletManager.getWallet(at: section)
            if wallet.records.count == 0 {
                return 1
            }
            return wallet.records.count
        case .date:
            let dates = recordManager.getAllDates()
            let records = recordManager.getAllRecords(for: dates[section])
            return records.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 30.0 }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 50.0 }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch walletManager.sortBy {
        case .wallet:
            return walletManager.getWallet(at: section).name
        case .date:
            let date = recordManager.getAllDates()[section]
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
            } else if Calendar.current.isDateInTomorrow(date) {
                return "Tomorrow"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                let dateString = dateFormatter.string(from: date)
                return dateString
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch walletManager.sortBy {
        case .wallet:
            return configureCellByWallet(tableView, at: indexPath)
        case .date:
            return configureCellByDate(tableView, at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let recordDetailsVC = RecordDetailsVC()
        switch walletManager.sortBy {
        case .wallet:
            guard let record = walletManager.getWallet(at: indexPath.section).records[safe: indexPath.row] else { return }
            AppCache.shared.selectedRecord = record
        case .date:
            let dates = recordManager.getAllDates()
            let record = recordManager.getAllRecords(for: dates[indexPath.section])[indexPath.row]
            AppCache.shared.selectedRecord = record
        }
        navigationController?.pushViewController(recordDetailsVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == numberOfSections(in: tableView) - 1 {
            return Constants.lastSectionFooterHeight
        } else {
            return Constants.normalSectionFooterHeight
        }
    }
    
}

private enum Constants {
    static let lastSectionFooterHeight = 100.0
    static let normalSectionFooterHeight = 15.0
}
