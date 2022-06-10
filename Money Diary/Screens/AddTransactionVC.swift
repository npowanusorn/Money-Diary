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
    private var currentHeight = Constants.defaultViewHeight
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPanGesture()

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
        UIView.animate(withDuration: Constants.duration) {
            self.contentViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func animateContentViewHeight(_ height: CGFloat) {
        UIView.animate(withDuration: Constants.duration) {
            self.contentViewHeightConstraint.constant = height
            self.view.layoutIfNeeded()
        }
        currentHeight = height
    }
    
    func setupConstraints() {
        contentViewBottomConstraint.constant = -Constants.defaultViewHeight
        contentViewHeightConstraint.constant = Constants.dismissHeight
        self.view.layoutIfNeeded()
    }
    
    func animateDimmedView() {
        dimView.alpha = 0
        dimView.fadeIn(withDuration: Constants.duration, alpha: Constants.maxDimAlpha)
    }
    
    func animateDismiss() {
        UIView.animate(withDuration: Constants.duration) {
            if self.currentHeight == Constants.defaultViewHeight {
                self.contentViewBottomConstraint.constant = -Constants.defaultViewHeight
            } else {
                self.contentViewBottomConstraint.constant = -Constants.maxHeight
            }
            self.view.layoutIfNeeded()
        }
        
        dimView.alpha = Constants.maxDimAlpha
        dimView.fadeOut(withDuration: Constants.duration) {
            self.dismiss(animated: false)
        }
    }
    
    func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        (pan.delaysTouchesBegan, pan.delaysTouchesEnded) = (false, false)
        view.addGestureRecognizer(pan)
    }
    
    @objc
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        print("y offset: \(translation.y)")
        
        let isDraggingDown = translation.y > 0
        print("drag dir: \(isDraggingDown ? "down" : "up")")
        
        let newHeight = currentHeight - translation.y
        print(newHeight)
        switch gesture.state {
        case .changed:
            if newHeight < Constants.maxHeight {
                contentViewHeightConstraint.constant = newHeight
                view.layoutIfNeeded()
            }
            
        case .ended:
            if newHeight < Constants.dismissHeight {
                self.animateDismiss()
            } else if newHeight < Constants.defaultViewHeight {
                animateContentViewHeight(Constants.defaultViewHeight)
            } else if newHeight < Constants.maxHeight && isDraggingDown {
                animateContentViewHeight(Constants.defaultViewHeight)
            } else if newHeight > Constants.defaultViewHeight && !isDraggingDown {
                animateContentViewHeight(Constants.maxHeight)
            }
            
        default:
            break
        }
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
        static let dismissHeight: CGFloat = 300
        static let maxHeight: CGFloat = UIScreen.main.bounds.height - 64
    }
}
