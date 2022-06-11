//
//  AddTransactionsVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-09.
//

import UIKit
import SPIndicator

class AddTransactionsVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    private var amountIsZero = true
    private var amountText: String {
        ""
    }
    private var noteText: String {
        ""
    }
    
    private var cellHeight: CGFloat = 100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.presentationController?.delegate = self
        
        title = "Add Transaction"
        let rightNavBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem = rightNavBarButtonItem
        
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "textFieldCell")
        tableView.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: "textViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCellHeight(_:)), name: Notification.Name(rawValue: "textViewDidChange"), object: nil)
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

    @IBAction func addButtonTapped(_ sender: Any) {
//        print(noteTextView.text ?? "nil")
//        print(amountTextField.text ?? "nil")
        SPIndicator.present(title: "Saved", preset: .done, haptic: .success)
        dismissView()
    }

    @objc
    func dismissView() {
        if amountText != "0" || !noteText.isEmpty {
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
}

extension AddTransactionsVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if amountText != "0" || !noteText.isEmpty {
            return false
        } else {
            return true
        }
    }
}

extension AddTransactionsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell", for: indexPath) as? TextFieldCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell", for: indexPath) as? TextViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40.0
        } else {
            return cellHeight
        }
    }
    
}
