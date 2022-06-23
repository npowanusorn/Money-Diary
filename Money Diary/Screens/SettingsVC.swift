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
//        var content = cell.defaultContentConfiguration()
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
    }
}
