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
    @IBOutlet var recentRecordTableView: UITableView!
    @IBOutlet var walletsTableHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tables = [walletsTableView, topSpendingTableView, recentRecordTableView]
        tables.forEach { table in
            table?.dataSource = self
            table?.delegate = self
            table?.rowHeight = Constants.cellHeight
        }
        walletsTableView.layer.cornerRadius = 12
        walletsTableHeight.constant = Constants.walletTableHeight
        walletsTableView.register(UINib(nibName: "WalletsCell", bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.walletCellIdentifier)
        topSpendingTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifier.topSpendingCellIdentifier)
        recentRecordTableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifier.recentCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.numberOfCells
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
//        let addTransactionVC = AddTransactionVC()
//        addTransactionVC.modalPresentationStyle = .overFullScreen
//        present(addTransactionVC, animated: false)
        
        
        let addVC = AddRecordVC()
        let navigation = UINavigationController(rootViewController: addVC)
//        if let sheet = navigation.sheetPresentationController {
//            sheet.detents = [.medium(), .large()]
//            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//            sheet.prefersEdgeAttachedInCompactHeight = true
//            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
//        }
        present(navigation, animated: true)
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
            cell.selectionStyle = .none
        } else {
            cell.walletName = "test wallet \(indexPath.row)"
            cell.walletBalance = "$\(indexPath.row)"
            cell.accessoryType = .disclosureIndicator
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
        guard let cell = recentRecordTableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.recentCellIdentifier) else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        content.text = "recents"
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
