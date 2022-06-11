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
    private var amountText: String {
        amountTextField.text ?? ""
    }
    private var noteText: String {
        noteTextView.text ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.presentationController?.delegate = self
        
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
