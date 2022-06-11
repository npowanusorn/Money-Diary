//
//  AddTransactionsVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-09.
//

import UIKit
import SPIndicator

class AddTransactionsVC: UIViewController {

    @IBOutlet private var noteTextView: UITextView!
    @IBOutlet private var amountTextField: UITextField!

    private var amountIsZero = true

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Transaction"
        let rightNavBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissView))
        navigationItem.rightBarButtonItem = rightNavBarButtonItem
        noteTextView.layer.cornerRadius = 12.0

        amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        print(noteTextView.text ?? "nil")
        print(amountTextField.text ?? "nil")
        let checkmarkImage = UIImage(systemName: "checkmark.circle.fill") ?? UIImage()
//        SPIndicator.present(title: "Saved", message: nil, preset: .custom(checkmarkImage), haptic: .success, from: .top) {
//            self.dismissView()
//        }
        let indicator = SPIndicatorView(title: "Saved", message: nil, preset: .done)
        indicator.titleLabel?.font = UIFont(name: "Avenir Next Bold", size: 17)
        SPIndicator.present(title: "Saved", preset: .done, haptic: .success)
        dismissView()
    }

    @objc
    func dismissView() {
        self.dismiss(animated: true)
    }
}
