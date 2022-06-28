//
//  AccountManagementVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 27/06/2022.
//

import UIKit

class AccountManagementVC: UIViewController {

    @IBOutlet private var tableView: UITableView!

//    private let sectionHeaderText = ["", "Danger Zone"]
//    private let cellText = [["Change password", ""], [""]]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Account Management"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
    }

    private func handleSelection() {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        if indexPath.section == CellSectionConfiguration.normal.rawValue {
            if CellSectionConfiguration.normal.getCellText()[indexPath.row] == "Change Password" {

            }
            if CellSectionConfiguration.normal.getCellText()[indexPath.row] == "Change Email" {
                let changeEmailVC = ChangeEmailVC()
                let navController = UINavigationController(rootViewController: changeEmailVC)
                self.present(navController, animated: true)
                return
            }
        }
        if indexPath.section == CellSectionConfiguration.danger.rawValue {
            if CellSectionConfiguration.danger.getCellText()[indexPath.row] == "Delete Account" {

            }
        }
        Log.error("ERROR SELECTION NOT HANDLED")
    }

}

extension AccountManagementVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        CellSectionConfiguration.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        CellSectionConfiguration.allCases[section].getSectionHeaderText()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 30.0 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CellSectionConfiguration.allCases[section].getCellText().count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 50.0 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = CellSectionConfiguration.allCases[indexPath.section].getCellText()[indexPath.row]
        if indexPath.section == CellSectionConfiguration.danger.rawValue {
            content.textProperties.color = .systemRed
        } else {
            content.textProperties.color = globalTintColor
        }
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSelection()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private extension AccountManagementVC {
    enum CellSectionConfiguration: Int, CaseIterable {
        case normal = 0
        case danger

        func getSectionHeaderText() -> String {
            switch self {
            case .normal:
                return "General"
            case .danger:
                return "Danger Zone"
            }
        }

        func getCellText() -> [String] {
            switch self {
            case .normal:
                return ["Change Password", "Change Email"]
            case .danger:
                return ["Delete Account"]
            }
        }
    }
}
