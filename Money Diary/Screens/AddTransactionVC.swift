//
//  AddTransactionVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-09.
//

import UIKit

class AddTransactionVC: UIViewController {

    @IBOutlet private var amountTextField: UITextField!
    @IBOutlet private var noteTextView: UITextView!
    @IBOutlet private var contentView: RoundedView!
    @IBOutlet private var dimView: UIView!
    @IBOutlet private var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var contentViewBottomConstraint: NSLayoutConstraint!
    
    private var amountIsZero = true
    private let defaultHeight: CGFloat = 350
    private let maxDimAlpha: CGFloat = 0.6
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        dimView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupConstraints()
        animateDimmedView()
        animateContentView()
    }
    
    func setupUI() {
        self.view.backgroundColor = .clear
        
        contentView.cornerRadius = 20
        
        noteTextView.delegate = self
        noteTextView.text = ""
        noteTextView.layer.cornerRadius = 8.0
        noteTextView.layer.borderColor = CGColor(red: 237, green: 237, blue: 241, alpha: 1)
        noteTextView.layer.borderWidth = 1
        
        title = "Add Transaction"
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir Next Regular", size: 17) ?? .systemFont(ofSize: 17)]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .done, target: self, action: #selector(dismissVC))
        amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        print(amountTextField.text ?? "nil")
        print(noteTextView.text ?? "nil")
        dismissVC()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        animateDismiss()
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
    func dismissVC() {
        animateDismiss()
    }
    
    func animateContentView() {
        UIView.animate(withDuration: 0.3) {
            self.contentViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func setupConstraints() {
        contentViewBottomConstraint.constant = -Constants.defaultViewHeight
        self.view.layoutIfNeeded()
    }
    
    func animateDimmedView() {
        dimView.alpha = 0
        dimView.fadeIn(withDuration: 0.4, alpha: Constants.maxDimAlpha)
    }
    
    func animateDismiss() {
        UIView.animate(withDuration: Constants.duration) {
            self.contentViewBottomConstraint.constant = -self.defaultHeight
            self.view.layoutIfNeeded()
        }
        
        dimView.alpha = maxDimAlpha
        dimView.fadeOut(withDuration: Constants.duration) {
            self.dismiss(animated: false)
        }
//        UIView.animate(withDuration: Constants.duration) {
//            self.dimView.alpha = 0
//        } completion: { _ in
//            self.dismiss(animated: false)
//        }
    }
}

extension AddTransactionVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text ?? "nil")
    }
}

extension AddTransactionVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedChars = CharacterSet.decimalDigits
        let charSet = CharacterSet(charactersIn: string)
        return allowedChars.isSuperset(of: charSet)
    }
}

extension AddTransactionVC {
    enum Constants {
        static let duration = 0.4
        static let defaultViewHeight: CGFloat = 350
        static let maxDimAlpha = 0.6
    }
}
