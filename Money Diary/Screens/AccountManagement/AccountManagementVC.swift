//
//  AccountManagementVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 27/06/2022.
//

import UIKit

class AccountManagementVC: UIViewController {

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedKeys.title

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
    }

    private func handleSelection() {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        if indexPath.section == CellSectionConfiguration.normal.rawValue {
            if CellSectionConfiguration.normal.getCellText()[indexPath.row] == LocalizedKeys.changePassword {
                let changePasswordVC = ChangePasswordVC()
                let navController = UINavigationController(rootViewController: changePasswordVC)
                self.present(navController, animated: true)
                return
            }
            if CellSectionConfiguration.normal.getCellText()[indexPath.row] == LocalizedKeys.changeEmail {
                let changeEmailVC = ChangeEmailVC()
                let navController = UINavigationController(rootViewController: changeEmailVC)
                self.present(navController, animated: true)
                return
            }
        }
        if indexPath.section == CellSectionConfiguration.danger.rawValue {
            if CellSectionConfiguration.danger.getCellText()[indexPath.row] == LocalizedKeys.deleteAccount {

            }
        }
        Log.error("ERROR SELECTION NOT HANDLED FOR SECTION \(indexPath.section):ROW \(indexPath.row)")
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
                return LocalizedKeys.general.localized
            case .danger:
                return LocalizedKeys.dangerZone.localized
            }
        }

        func getCellText() -> [String] {
            switch self {
            case .normal:
                return [LocalizedKeys.changePassword, LocalizedKeys.changeEmail]
            case .danger:
                return [LocalizedKeys.deleteAccount]
            }
        }
    }

    enum LocalizedKeys {
        static let general = "account_management_section_general".localized
        static let dangerZone = "account_management_section_danger_zone".localized
        static let title = "account_management_title".localized
        static let changePassword = "account_management_change_password".localized
        static let changeEmail = "account_management_change_email".localized
        static let deleteAccount = "account_management_delete_account".localized
    }
}
