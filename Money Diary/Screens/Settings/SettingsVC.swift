//
//  SettingsVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-19.
//

import UIKit
import SPSettingsIcons

class SettingsVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "settingsCell")

        tableView.tableFooterView = getLogOutView()
    }

    private func getLogOutView() -> UIView {
        let logOutView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
//        logOutView.backgroundColor = .yellow
        var buttonConfiguration = UIButton.Configuration.filled()
        let attributedTitle = NSAttributedString(string: "Log out", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15.0, weight: .bold)])
        buttonConfiguration.attributedTitle = AttributedString(attributedTitle)
        buttonConfiguration.baseBackgroundColor = .systemRed
        buttonConfiguration.baseForegroundColor = .white
        buttonConfiguration.background.strokeWidth = 1.0
        buttonConfiguration.cornerStyle = .large
        let button = UIButton(configuration: buttonConfiguration)
        button.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        logOutView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.centerXAnchor.constraint(equalTo: logOutView.centerXAnchor, constant: 0).isActive = true
        button.centerYAnchor.constraint(equalTo: logOutView.centerYAnchor, constant: 0).isActive = true

//        button.leadingAnchor.constraint(equalTo: logOutView.leadingAnchor, constant: 40).isActive = true
//        button.trailingAnchor.constraint(equalTo: logOutView.trailingAnchor, constant: 40).isActive = true
//        button.topAnchor.constraint(equalTo: logOutView.topAnchor, constant: 0).isActive = true
//        button.bottomAnchor.constraint(equalTo: logOutView.bottomAnchor, constant: 0).isActive = true
        return logOutView
    }

    @objc
    func logOut() {
        UserDefaults.standard.set(false, forKey: K.UserDefaultsKeys.isLoggedIn)
        navigationController?.popToRootViewController(animated: true)
    }

}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "header"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as? ImageCell else { return UITableViewCell() }
//        content.text = "Theme \(indexPath.row + 1)"
//        content.image = UIImage.generateSettingsIcon("paintpalette.fill", backgroundColor: globalTintColor)
//        cell.contentConfiguration = content
        cell.primaryText = "Theme \(indexPath.row + 1)"
        cell.secondaryText = "text"
        cell.cellImage = UIImage.generateSettingsIcon("paintpalette.fill", backgroundColor: globalTintColor)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            globalTintColor = .systemRed
        } else {
            globalTintColor = .systemTeal
        }
        self.navigationController?.navigationBar.tintColor = globalTintColor
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .filter({ $0.isKeyWindow }).first
        keyWindow?.reload()
    }
}
