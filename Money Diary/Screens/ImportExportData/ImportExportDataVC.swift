//
//  ImportExportDataVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-11-06.
//

import UIKit

class ImportExportDataVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()
        title = "Data"
    }

    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
    }

    func handleImportData() {
        Log.info("HANDLE IMPORT DATA")
        present(UIAlertController.showNotImplementedAlert(), animated: true)
    }

    func handleExportData() {
        Log.info("HANDLE EXPORT DATA")
        present(UIAlertController.showNotImplementedAlert(), animated: true)
    }

}

extension ImportExportDataVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { ImportExportCells.allCases.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentRow = ImportExportCells(rawValue: indexPath.row),
              let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)") else {
            return UITableViewCell()
        }
        var content = cell.defaultContentConfiguration()
        content.text = currentRow.getName()
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let currentRow = ImportExportCells(rawValue: indexPath.row) else { return }
        switch currentRow {
        case .importData:
            handleImportData()
        case .exportData:
            handleExportData()
        }
    }
}

private enum ImportExportCells: Int, CaseIterable {
    case importData, exportData

    func getName() -> String {
        switch self {
        case .importData:
            return "Import Data"
        case .exportData:
            return "Export Data"
        }
    }
}
