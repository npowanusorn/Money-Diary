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

    private let keychain = KeychainSwift()

    @IBOutlet private var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.tableFooterView = getTableFooterView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = LocalizedKeys.title.localized
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.nibName, bundle: nil), forCellReuseIdentifier: Constants.identifier)
    }

    private func getTableFooterView() -> UIView {
        let logOutView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 120))
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.attributedTitle = getAttributedString(
            for: LocalizedKeys.logOut.localized,
            fontSize: 15.0, weight: .bold
        )
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
        currentEmailLabel.text = LocalizedKeys.loggedInWith.localizeWithFormat(arguments: currentEmail)
        currentEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        logOutView.addSubview(currentEmailLabel)
        
        currentEmailLabel.centerXAnchor.constraint(equalTo: logOutView.centerXAnchor).isActive = true
        currentEmailLabel.topAnchor.constraint(equalTo: logOutView.topAnchor, constant: 0).isActive = true
        
        return logOutView
    }

    @objc
    func logOutTapped() {
        let alert = UIAlertController.showAlert(
            with: LocalizedKeys.logOut.localized,
            message: LocalizedKeys.logOutMessage.localized,
            style: .alert,
            primaryActionName: LocalizedKeys.logOut.localized,
            primaryActionStyle: .destructive,
            secondaryActionName: LocalizedKeys.cancel.localized,
            secondaryActionStyle: .cancel) {
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
        clearAllData()
        let welcomeVC = WelcomeVC()
        guard let navigationController = navigationController else { return }
        let navigationArray: [UIViewController] = [welcomeVC] + navigationController.viewControllers
        self.navigationController?.viewControllers = navigationArray
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func navigateToVC() {
        if let row = tableView.indexPathForSelectedRow?.row {
            switch row {
            case SettingsCellList.AppTheme.rawValue:
                Log.info("GO TO APP THEME VC")
            case SettingsCellList.Account.rawValue:
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
        return SettingsCellList.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.identifier,
            for: indexPath
        ) as? ImageCell else { return UITableViewCell() }
        cell.primaryText = SettingsCellList.allCases[indexPath.row].name()
        if indexPath.row == SettingsCellList.AppTheme.rawValue {
            cell.secondaryText = "Dark"
            cell.cellImage = UIImage.generateSettingsIcon(ImageName.appThemeIcon, backgroundColor: globalTintColor)
        }
        if indexPath.row == SettingsCellList.Account.rawValue {
            cell.cellImage = UIImage.generateSettingsIcon(ImageName.accountIcon, backgroundColor: globalTintColor)
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
    enum SettingsCellList: Int, CaseIterable {
        case AppTheme = 0
        case Account

        func name() -> String {
            switch self {
            case .AppTheme:
                return LocalizedKeys.appTheme.localized
            case .Account:
                return LocalizedKeys.account.localized
            }
        }
    }
}

private extension SettingsVC {
    enum Constants {
        static let nibName = "ImageCell"
        static let identifier = "\(ImageCell.self)"
    }
    enum ImageName {
        static let appThemeIcon = "paintpalette.fill"
        static let accountIcon = "person.crop.circle.fill"
    }
    enum LocalizedKeys {
        static let appTheme = "settings_app_theme"
        static let account = "settings_account"
        static let title = "settings_title"
        static let logOut = "settings_log_out"
        static let logOutMessage = "settings_log_out_message"
        static let loggedInWith = "settings_logged_in_with"
        static let cancel = "settings_cancel"
    }

}
