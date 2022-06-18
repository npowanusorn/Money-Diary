//
//  AddTransactionsVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-09.
//

import UIKit
import SPIndicator

protocol AddedTransactionDelegate {
    func didAddTransaction(transaction: Transaction)
}

class AddTransactionsVC: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    private var amountIsZero = true
    private var amountText = ""
    private var noteText = ""
    
    private var cellHeight: CGFloat = 100.0
    
    private var canDismissScreen: Bool {
        return amountText.isEmpty && noteText.isEmpty
    }

    private var selectedDateString = "Today"
    private var selectedDate = Date()

    private var rightNavBarButtonItem: UIBarButtonItem?

    var delegate: AddedTransactionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.presentationController?.delegate = self

        title = "Add Transaction"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)]
        let leftNavBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissView))
        rightNavBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addAction))
        rightNavBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem = leftNavBarButtonItem
        navigationItem.rightBarButtonItem = rightNavBarButtonItem
        
        tableView.register(TextViewCell.self, forCellReuseIdentifier: "textViewCell")
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: "datePickerCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 12
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCellHeight(_:)), name: Notification.Name(rawValue: "textViewDidChange"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
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
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let primaryAction = UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
                self.dismiss(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertVC.addAction(primaryAction)
            alertVC.addAction(cancelAction)
            present(alertVC, animated: true)
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
        let transaction = Transaction(amount: Double(amountText) ?? 0.0, notes: noteText, date: selectedDate, walletIndex: WalletManager.shared.chosenWalletIndex)
        delegate?.didAddTransaction(transaction: transaction)
        dismiss(animated: true)
    }
}

extension AddTransactionsVC: TextViewCellDelegate {
    func textViewDidChange(text: String, tag: Int) {
        if tag == 0 {
            amountText = text
            rightNavBarButtonItem?.isEnabled = !amountText.isEmpty
        } else if tag == 1 {
            noteText = text
        } else { return }
    }
}

extension AddTransactionsVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if canDismissScreen {
            return true
        } else {
            let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let primaryAction = UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
                self.dismiss(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertVC.addAction(primaryAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true)
            return false
        }
    }
}

extension AddTransactionsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        " "
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        } else {
            return 2
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as? TextViewCell else { return UITableViewCell() }
            cell.delegate = self
            if indexPath.row == 0 {
                cell.setPlaceholder(with: "Amount")
                cell.textView?.tag = 0
            } else {
                cell.setPlaceholder(with: "Note")
                cell.textView?.tag = 1
            }
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 1 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            var content = cell.defaultContentConfiguration()
            content.textProperties.font = UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
            content.text = "Wallet"
            content.secondaryText = WalletManager.shared.getWallets(at: WalletManager.shared.chosenWalletIndex).name
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                var content = cell.defaultContentConfiguration()
                content.textProperties.font = UIFont(name: "Avenir Next Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
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
        if indexPath.row == 0 {
            return 50.0
        } else if indexPath.row == 1 && indexPath.section == 2 {
            return 350.0
        } else if indexPath.section == 1{
            return 50
        } else {
            return cellHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let walletsListVC = WalletsListVC()
            navigationController?.pushViewController(walletsListVC, animated: true)
        }
    }
    
}

extension AddTransactionsVC: DatePickerCellDelegate {
    func didSelectDate(date: Date) {
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
        let indexPath = IndexPath(row: 0, section: 2)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
