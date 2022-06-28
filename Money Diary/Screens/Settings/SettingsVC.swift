//
//  SettingsVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-19.
//

import UIKit
import SPSettingsIcons
import SPIndicator
import Firebase
import KeychainSwift

class SettingsVC: UIViewController {
    
    let settingsCellList: [String] = ["App Theme", "Account Management"]

    private let keychain = KeychainSwift()

    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "settingsCell")

        tableView.tableFooterView = getLogOutView()
    }

    private func getLogOutView() -> UIView {
        let logOutView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 150))
//        logOutView.backgroundColor = .yellow
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.attributedTitle = getAttributedString(for: "Log out", fontSize: 15.0, weight: .bold)
        buttonConfiguration.baseBackgroundColor = .systemRed
        buttonConfiguration.baseForegroundColor = .white
        buttonConfiguration.background.strokeWidth = 1.0
        buttonConfiguration.cornerStyle = .large
        let button = BounceButton(configuration: buttonConfiguration)
        button.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
        logOutView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.centerXAnchor.constraint(equalTo: logOutView.centerXAnchor, constant: 0).isActive = true
        button.centerYAnchor.constraint(equalTo: logOutView.centerYAnchor, constant: 0).isActive = true

        guard let currentEmail = Auth.auth().currentUser?.email else {
            return logOutView
        }
        let currentEmailLabel = UILabel()
        currentEmailLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        currentEmailLabel.text = "Logged in with \(currentEmail)"
        currentEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        logOutView.addSubview(currentEmailLabel)
        
        currentEmailLabel.centerXAnchor.constraint(equalTo: logOutView.centerXAnchor).isActive = true
        currentEmailLabel.topAnchor.constraint(equalTo: logOutView.topAnchor, constant: 0).isActive = true
        
//        buttonConfiguration.attributedTitle = getAttributedString(for: "Delete account", fontSize: 15.0, weight: .bold)
//        let deleteAccountButton = BounceButton(configuration: buttonConfiguration)
//        logOutView.addSubview(deleteAccountButton)
//        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
//        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
//        
//        deleteAccountButton.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20).isActive = true
//        deleteAccountButton.centerXAnchor.constraint(equalTo: logOutView.centerXAnchor).isActive = true
//        deleteAccountButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
//        deleteAccountButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return logOutView
    }

    @objc
    func logOutTapped() {
        let alert = UIAlertController.showAlert(with: "Log out", message: nil, style: .alert, primaryActionName: "Log out", primaryActionStyle: .destructive, secondaryActionName: "Cancel", secondaryActionStyle: .cancel) {
            self.handleLogOut()
        }
        self.present(alert, animated: true)
    }
    
    func handleLogOut() {
        UserDefaults.standard.set(false, forKey: K.UserDefaultsKeys.isLoggedIn)
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            Log.error("ERROR SIGNING OUT: \(error)")
            let alert = UIAlertController.showDismissAlert(with: "Error", message: error.localizedDescription)
            self.present(alert, animated: true)
            SPIndicator.present(title: "Error", message: "Unable to sign out", preset: .error, haptic: .error)
            return
        }
        SPIndicator.present(title: "Success", message: "Signed out", preset: .done, haptic: .success)
        WalletManager.shared.removeAllWallets()
        RecordManager.shared.removeAllRecords()
        keychain.clear()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    func deleteAccountTapped() {
        if let email = Auth.auth().currentUser?.email {
            let alert = UIAlertController.showTextFieldAlert(with: "Delete account", message: "Type in your email to continue", actionTitle: "Continue") { textField in
                if textField.text == email {
                    self.handleDeleteAccount()
                }
            }
            self.present(alert, animated: true)
        }
    }
    
    func handleDeleteAccount() {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                Log.error("ERROR DELETING ACCOUNT: \(error)")
                self.present(UIAlertController.showErrorAlert(message: error.localizedDescription), animated: true)
                return
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    func navigateToVC() {
        if let row = tableView.indexPathForSelectedRow?.row {
            switch row {
            case SettingsCellList.AppTheme.rawValue:
                Log.info("GO TO APP THEME VC")
            case SettingsCellList.AccountManagement.rawValue:
                Log.info("GO TO ACCOUNT MGMT VC")
                let accountManagementVC = AccountManagementVC()
                navigationController?.pushViewController(accountManagementVC, animated: true)
            default:
                Log.info("DEFAULT")
                return
            }
        }
    }

}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsCellList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as? ImageCell else { return UITableViewCell() }
//        content.text = "Theme \(indexPath.row + 1)"
//        content.image = UIImage.generateSettingsIcon("paintpalette.fill", backgroundColor: globalTintColor)
//        cell.contentConfiguration = content
        cell.primaryText = settingsCellList[indexPath.row]
        if indexPath.row == SettingsCellList.AppTheme.rawValue {
            cell.secondaryText = "App Theme"
            cell.cellImage = UIImage.generateSettingsIcon("paintpalette.fill", backgroundColor: globalTintColor)
        }
        if indexPath.row == SettingsCellList.AccountManagement.rawValue {
            cell.cellImage = UIImage.generateSettingsIcon("person.crop.circle.fill", backgroundColor: globalTintColor)
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToVC()
        tableView.deselectRow(at: indexPath, animated: true)

//        self.navigationController?.navigationBar.tintColor = globalTintColor
//        let keyWindow = UIApplication.shared.connectedScenes
//            .filter({ $0.activationState == .foregroundActive })
//            .compactMap({ $0 as? UIWindowScene })
//            .first?.windows
//            .filter({ $0.isKeyWindow }).first
//        keyWindow?.reload()
    }
}

private extension SettingsVC {
    enum SettingsCellList: Int {
        case AppTheme = 0
        case AccountManagement
    }
}
