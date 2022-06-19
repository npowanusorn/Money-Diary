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
    private let recordManager = TransactionManager.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.sizeToFit()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(LeftRightLabelCell.self, forCellReuseIdentifier: "allRecordsCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        title = "All records"
    }

}

extension AllRecordsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return walletManager.numberOfWallets
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if recordManager.getAllTransactions(for: section).count == 0 {
            return 1
        }
        return recordManager.getAllTransactions(for: section).count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return walletManager.getWallet(at: section).name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allRecordsCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.font = UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        content.secondaryTextProperties.font = UIFont(name: "Avenir Next Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        let records = walletManager.getWallet(at: indexPath.section).transactions
        if records.count == 0 {
            content.text = "No record available"
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        }
        let record = records[indexPath.row]
        content.text = record.notes
        content.secondaryText = String(format: "$%.2f", record.amount)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        print(record)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
