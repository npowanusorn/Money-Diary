//
//  ImportExportDataVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-11-06.
//

import UIKit
import SwiftCSV

class ImportExportDataVC: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTable()
        title = LocalizedKeys.title.localized
    }

    func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.nibName, bundle: nil), forCellReuseIdentifier: Constants.identifier)
    }

    func handleImportDataCellTapped() {
        Log.info("HANDLE IMPORT DATA")
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.commaSeparatedText, .tabSeparatedText, .utf8TabSeparatedText]
        )
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .overCurrentContext
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }

    func handleExportDataCellTapped() {
        Log.info("HANDLE EXPORT DATA")
        present(UIAlertController.showNotImplementedAlert(), animated: true)
    }

    func handleParseCSV(from url: URL) {
        do {
            let csv = try NamedCSV(url: url)
            handleImportData(from: csv)
        } catch {
            Log.error(error.localizedDescription)
            let alert = UIAlertController.showErrorAlert(message: error.localizedDescription)
            present(alert, animated: true)
        }
    }

    func handleImportData(from csv: NamedCSV) {
        let rows = csv.rows
        var rowsForWallet: [String: [[String: String]]] = [:]
        for row in rows {
            guard let walletForRow = row[Constants.walletCSVID] else { return }
            if rowsForWallet[walletForRow] == nil {
                rowsForWallet[walletForRow] = []
            }
            rowsForWallet[walletForRow]!.append(row)
        }
        for walletKey in rowsForWallet.keys {
            let walletCurrencyString = rowsForWallet[walletKey]!.last!["Currency"]!
            let walletCurrency = CurrencyType(rawValue: walletCurrencyString) ?? .CAD
            let wallet = Wallet(name: walletKey, balance: 0, type: .bank, dateCreated: .now, currency: walletCurrency)
            Task {
                WalletManager.shared.addWallet(newWallet: wallet)
                await FirestoreManager.writeData(forWallet: wallet)
            }
            let records = rowsForWallet[walletKey]!
            for record in records {
                let amount = Double(record["Amount"]!)!
                let absAmount = abs(amount)
                let note = record["Note"]!
                let date = getDate(from: record["Date"]!, with: "dd/MM/yyyy") ?? .now
                let walletID = wallet.id
                let currency = CurrencyType(rawValue: record["Currency"]!) ?? .CAD
                let newRecord = Record(
                    amount: absAmount,
                    note: note,
                    date: date,
                    walletID: walletID,
                    isExpense: amount < 0,
                    currency: currency
                )
                Task {
                    WalletManager.shared.addRecordToWallet(record: newRecord)
                    await FirestoreManager.writeData(forRecord: newRecord)
                }
            }
        }
    }

}

extension ImportExportDataVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { ImportExportCells.allCases.count }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 50 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentRow = ImportExportCells(rawValue: indexPath.row),
              let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifier) as? ImageCell else {
            return UITableViewCell()
        }
        cell.primaryText = currentRow.getName()
        cell.accessoryType = .disclosureIndicator
        switch currentRow {
        case .importData:
            cell.cellImage = .generateSettingsIcon(Constants.importImage, backgroundColor: globalTintColor)
        case .exportData:
            cell.cellImage = .generateSettingsIcon(Constants.exportImage, backgroundColor: globalTintColor)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let currentRow = ImportExportCells(rawValue: indexPath.row) else { return }
        switch currentRow {
        case .importData:
            handleImportDataCellTapped()
        case .exportData:
            handleExportDataCellTapped()
        }
    }
}

extension ImportExportDataVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        dismiss(animated: true)
        guard urls.count == 1, let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        handleParseCSV(from: url)
    }
}

private enum ImportExportCells: Int, CaseIterable {
    case importData, exportData

    func getName() -> String {
        switch self {
        case .importData:
            return LocalizedKeys.importData.localized
        case .exportData:
            return LocalizedKeys.exportData.localized
        }
    }
}

private enum Constants {
    static let nibName = "ImageCell"
    static let identifier = "\(ImageCell.self)"
    static let importImage = "square.and.arrow.down.fill"
    static let exportImage = "square.and.arrow.up.fill"
    static let walletCSVID = "Wallet"
}

private enum LocalizedKeys {
    static let title = "data_title"
    static let importData = "data_import"
    static let exportData = "data_export"
}
