//
//  DashboardViewController.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-05.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet var walletsTableView: UITableView!
    @IBOutlet var topSpendingTableView: UITableView!
    @IBOutlet var recentTransactionsTableView: UITableView!
    @IBOutlet var walletsTableHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tables = [walletsTableView, topSpendingTableView, recentTransactionsTableView]
        tables.forEach { table in
            table?.dataSource = self
            table?.delegate = self
            table?.rowHeight = Constants.cellHeight
        }
        
        walletsTableHeight.constant = Constants.walletTableHeight
        walletsTableView.register(UINib(nibName: "WalletsCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.walletCellIdentifier)
        topSpendingTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifier.topSpendingCellIdentifier)
        recentTransactionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifier.recentCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfCells
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let addTransactionVC = AddTransactionVC()
        addTransactionVC.modalPresentationStyle = .overCurrentContext
//        let navigation = UINavigationController(rootViewController: addTransactionVC)
//        navigation.modalPresentationStyle = .overCurrentContext
        present(addTransactionVC, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == walletsTableView {
            return configureWalletsTableView(for: indexPath)
        } else if tableView == topSpendingTableView {
            return configureTopSpendingTableView(for: indexPath)
        } else {
            return configureRecentsTableView(for: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDatasource
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func configureWalletsTableView(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = walletsTableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.walletCellIdentifier) as? WalletsCell else { return UITableViewCell() }
        if indexPath.row == 0 {
            cell.walletName = "My Wallets"
            cell.makeNameLabelBold()
            cell.isBalanceHidden = true
        } else {
            cell.walletName = "test wallet \(indexPath.row)"
            cell.walletBalance = "$\(indexPath.row)"
        }
        return cell
    }
    
    func configureTopSpendingTableView(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = topSpendingTableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.topSpendingCellIdentifier) else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        content.text = "topSpending"
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        return cell
    }
    
    func configureRecentsTableView(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = recentTransactionsTableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.recentCellIdentifier) else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        content.text = "recents"
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - Constants
extension DashboardViewController {
    enum Constants {
        enum CellIdentifier {
            static let walletCellIdentifier = "walletCell"
            static let topSpendingCellIdentifier = "topSpendingCell"
            static let recentCellIdentifier = "recentCell"
        }
        static let numberOfCells = 5
        static let cellHeight: CGFloat = 50
        static let walletTableHeight: CGFloat = cellHeight * CGFloat(numberOfCells)
    }
}
