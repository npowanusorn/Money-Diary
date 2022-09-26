//
//  AddRecordVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-09.
//

import UIKit
import SPIndicator
import RealmSwift

protocol AddedRecordDelegate {
    func didAddRecord(record: Record)
}

class AddRecordVC: UIViewController {

    @IBOutlet private var tableView: UITableView!

    private var amountIsZero = true
    private var amountText = ""
    private var noteText = ""
    private var isExpense: Bool = true
    
    private var cellHeight: CGFloat = 100.0
    private var dateDidChange: Bool = false
    private var canDismissScreen: Bool {
        return amountText.isEmpty && noteText.isEmpty && !dateDidChange
    }

    private var selectedDateString = "Today"
    private var selectedDate = Date()

    private var rightNavBarButtonItem: UIBarButtonItem?

    var delegate: AddedRecordDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.presentationController?.delegate = self

        title = "Add Record"
        let leftNavBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissView))
        rightNavBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addAction))
        rightNavBarButtonItem?.isEnabled = false
        rightNavBarButtonItem?.tintColor = globalTintColor
        navigationItem.leftBarButtonItem = leftNavBarButtonItem
        navigationItem.rightBarButtonItem = rightNavBarButtonItem
        
        tableView.register(TextViewCell.self, forCellReuseIdentifier: "textViewCell")
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: "datePickerCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TabBarViewCell.self, forCellReuseIdentifier: "tabBarViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCellHeight(_:)),
            name: "textViewDidChange",
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
    }

    @objc
    func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.isEmpty {
            textField.text = "0"
            amountIsZero = true
            return
        }
        if Int(text) == 0 {
            textField.text = "0"
            amountIsZero = true
            return
        }
        if amountIsZero, Int(text) != 0, !text.contains(".") {
            amountIsZero = false
            textField.text?.removeFirst()
        }
    }

    @objc
    func dismissView() {
        if !canDismissScreen {
            let alert = UIAlertController.showUnsavedChangesSheet {
                self.dismiss(animated: true)
            }
            present(alert, animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc
    func updateCellHeight(_ notification: Notification) {
        if let height = notification.userInfo?["height"] as? CGFloat {
            cellHeight = height > 100 ? height : 100
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    @objc
    func addAction() {
        let chosenWalletID = WalletManager.shared.getWallet(at: WalletManager.shared.chosenWalletIndex).id
        let record = Record(amount: Double(amountText) ?? 0.0, note: noteText, date: selectedDate, walletID: chosenWalletID, isExpense: isExpense)
        WalletManager.shared.addRecordToWallet(record: record)
        if UserDefaults.standard.bool(forKey: K.UserDefaultsKeys.localAccount) {
            do {
                Log.info("**** WRITING TO REALM ****")
                let realm = try Realm()
                let wallet = WalletManager.shared.getWallet(at: WalletManager.shared.chosenWalletIndex)
                try realm.write {
                    realm.add(record)
                    wallet.addRecord(newRecord: record)
                }
            } catch {
                Log.error("REALM WRITE ERROR: \(error)")
            }
        } else {
            Task { await FirestoreManager.writeData(forRecord: record) }
        }
        delegate?.didAddRecord(record: record)
        dismiss(animated: true)
    }
}

extension AddRecordVC: TextViewCellDelegate {
    func textViewDidChange(text: String, tag: Int) {
        if tag == 0 {
            amountText = text
            rightNavBarButtonItem?.isEnabled = !amountText.isEmpty
        } else if tag == 1 {
            noteText = text
        } else { return }
    }
}

extension AddRecordVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if canDismissScreen {
            return true
        } else {
            let alert = UIAlertController.showUnsavedChangesSheet {
                self.dismiss(animated: true)
            }
            present(alert, animated: true)
            return false
        }
    }
}

extension AddRecordVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        " "
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 2 {
            return 1
        } else {
            return 2
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "tabBarViewCell", for: indexPath) as? TabBarViewCell else { return UITableViewCell() }
            cell.setTitles(titles: ["Expense", "Income"])
            cell.setStyle(style: .fill)
            cell.delegate = self
            cell.selectionStyle = .none
            cell.accessoryType = .none
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as? TextViewCell else { return UITableViewCell() }
            cell.delegate = self
            if indexPath.row == 0 {
                cell.setPlaceholder(with: "Amount")
                cell.textView?.keyboardType = .decimalPad
                cell.textView?.tag = 0
            } else {
                cell.setPlaceholder(with: "Note")
                cell.textView?.tag = 1
            }
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 2 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            var content = cell.defaultContentConfiguration()
            content.text = "Wallet"
            content.secondaryText = WalletManager.shared.getWallet(at: WalletManager.shared.chosenWalletIndex).name
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                var content = cell.defaultContentConfiguration()
                content.text = "Date"
                content.secondaryText = selectedDateString
                cell.contentConfiguration = content
                cell.selectionStyle = .none
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell") as? DatePickerCell else { return UITableViewCell() }
                cell.selectionStyle = .none
                cell.delegate = self
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 40.0
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                return 50.0
            } else {
                return cellHeight
            }
        } else if indexPath.section == 2 {
            return 50.0
        } else {
            if indexPath.row == 0 {
                return 50.0
            } else {
                return 350.0
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            let walletsListVC = WalletsListVC()
            navigationController?.pushViewController(walletsListVC, animated: true)
        }
    }
    
}

extension AddRecordVC: DatePickerCellDelegate {
    func didSelectDate(date: Date) {
        dateDidChange = true
        selectedDate = date
        if Calendar.current.isDateInToday(date) {
            selectedDateString = "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            selectedDateString = "Yesterday"
        } else if Calendar.current.isDateInTomorrow(date) {
            selectedDateString = "Tomorrow"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = dateFormatter.string(from: date)
            selectedDateString = dateString
        }
        let indexPath = IndexPath(row: 0, section: 3)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension AddRecordVC: TabBarCellDelegate {
    func didChangeToIndex(index: Int) {
        isExpense = index == 0 ? true : false
    }
}
