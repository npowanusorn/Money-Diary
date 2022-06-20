//
//  WalletDetailVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-18.
//

import UIKit

class WalletDetailVC: UIViewController {

    var selectedWalletIndex: Int!
    
    private var wallet: Wallet!
    private let walletManager = WalletManager.shared
    private let recordManager = RecordManager.shared
    private let tabViewButtonTitles = ["All", "Expenses", "Income"]
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noRecordFoundView: UIView!
    @IBOutlet private var balanceView: RoundedView!
    @IBOutlet private var balanceLabel: UILabel!
    @IBOutlet private var tabBarView: SwipeTabView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarView.setButtonTitles(buttonTitles: tabViewButtonTitles)
        tabBarView.delegate = self
        tabBarView.backgroundColor = .secondarySystemGroupedBackground
        
        wallet = walletManager.getWallet(at: selectedWalletIndex)
        guard wallet != nil else { return }
        title = wallet.name
        
        noRecordFoundView.isHidden = !wallet.records.isEmpty
        tableView.isHidden = wallet.records.isEmpty
        balanceView.isHidden = wallet.records.isEmpty
        balanceLabel.text = "Balance: \(getWalletBalance())"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LeftRightLabelCell.self, forCellReuseIdentifier: "walletDetailCell")
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle.fill"), style: .plain, target: self, action: #selector(getWalletInfo))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    @IBAction func addRecordTapped(_ sender: Any) {
        walletManager.chosenWalletIndex = selectedWalletIndex
        let addRecordVC = AddRecordVC()
        addRecordVC.delegate = self
        let navigation = UINavigationController(rootViewController: addRecordVC)
        present(navigation, animated: true)
    }
    
    func refreshScreen() {
        noRecordFoundView.isHidden = !wallet.records.isEmpty
        tableView.isHidden = wallet.records.isEmpty
        balanceView.isHidden = wallet.records.isEmpty
        balanceLabel.text = "Balance: \(getWalletBalance())"
        tableView.reloadData()
    }
    
    func getWalletBalance() -> String {
        var amount = wallet.balance
        for record in wallet.records {
            amount -= record.amount
        }
        return String(format: "$%.2f", amount)
    }
    
    @objc
    func getWalletInfo() {
        print("info")
    }
}

// MARK: - TableView
extension WalletDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recordManager.getAllDatesSorted(for: selectedWalletIndex).count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        let date = recordManager.getAllDatesSorted(for: selectedWalletIndex)[section - 1]
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        let dates = recordManager.getAllDatesSorted(for: selectedWalletIndex)
        return recordManager.getAllRecords(for: dates[section - 1], in: selectedWalletIndex).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletDetailCell", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        content.textProperties.font = K.Fonts.avenirNextRegular17
        if indexPath.section == 0 {
            content.text = "Balance: \(getWalletBalance())"
            content.textProperties.alignment = .center
            content.textProperties.font = UIFont(name: "Avenir Next Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
            cell.contentConfiguration = content
            return cell
        }
        let dates = recordManager.getAllDatesSorted(for: selectedWalletIndex)
        let record = recordManager.getAllRecords(for: dates[indexPath.section - 1], in: selectedWalletIndex)[indexPath.row]
        content.text = record.notes
        content.secondaryText = String(format: "$%.2f", record.amount)
        
        cell.contentConfiguration = content
        return cell
    }
}

extension WalletDetailVC: AddedRecordDelegate {
    func didAddRecord(record: Record) {
        wallet = walletManager.getWallet(at: selectedWalletIndex)
        refreshScreen()
    }
}

extension WalletDetailVC: SwipeTabViewDelegate {
    func didChangeToIndex(index: Int) {
        print("did change to index: \(index)")
    }
}
