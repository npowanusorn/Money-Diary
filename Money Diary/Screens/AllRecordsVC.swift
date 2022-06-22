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

        alertController.addAction(walletAction)
        alertController.addAction(dateAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func configureCellByWallet(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRecordsCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
//        content.textProperties.font = UIFont.systemFont(ofSize: 17)
//        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 15)
        let records = recordManager.getAllRecords(forWalledIndex: indexPath.section)
//        let records = walletManager.getWallet(at: indexPath.section).records
        if records.count == 0 {
            content.text = "No record available"
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            cell.accessoryType = .none
            return cell
        } else {
            let record = records[indexPath.row]
            content.text = record.notes
            content.secondaryText = record.amount.toCurrencyString()
            content.secondaryTextProperties.color = record.isExpense ? .systemRed : .systemBlue
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func configureCellByDate(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRecordsCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
//        content.textProperties.font = UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
//        content.secondaryTextProperties.font = UIFont(name: "Avenir Next Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        let dates = recordManager.getAllDatesSorted()
        let record = recordManager.getAllRecords(forDate: dates[indexPath.section])[indexPath.row]
        content.text = record.notes
        content.secondaryText = record.amount.toCurrencyString()
        content.secondaryTextProperties.color = record.isExpense ? .systemRed : .systemBlue
        cell.contentConfiguration = content
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
            return recordManager.getAllDatesSorted().count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch walletManager.sortBy {
        case .wallet:
            if recordManager.getAllRecords(forWalledIndex: section).count == 0 {
                return 1
            }
            return recordManager.getAllRecords(forWalledIndex: section).count
        case .date:
            let dates = recordManager.getAllDatesSorted()
            let records = recordManager.getAllRecords(forDate: dates[section])
            return records.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch walletManager.sortBy {
        case .wallet:
            return walletManager.getWallet(at: section).name
        case .date:
            let date = recordManager.getAllDatesSorted()[section]
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
        switch walletManager.sortBy {
        case .wallet:
            let recordDetailsVC = RecordDetailsVC()
            recordDetailsVC.selectedRecord = recordManager.getAllRecords(forWalledIndex: indexPath.section)[indexPath.row]
            navigationController?.pushViewController(recordDetailsVC, animated: true)
        case .date:
            return
        }
    }
    
}
