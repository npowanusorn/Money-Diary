//
//  DashboardViewController.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-05.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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

extension DashboardViewController {
    func configureWalletsTableView(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = walletsTableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.walletCellIdentifier) as? WalletsCell else { return UITableViewCell() }
        cell.walletName = "test wallet \(indexPath.row)"
        cell.walletBalance = "$\(indexPath.row)"
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
