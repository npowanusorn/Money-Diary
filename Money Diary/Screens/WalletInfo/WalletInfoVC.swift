//
//  WalletInfoVC.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-09-19.
//

import UIKit

class WalletInfoVC: UIViewController {

    @IBOutlet private weak var textFieldView: UIView!
    @IBOutlet private weak var walletNameTextField: UITextField!
    @IBOutlet private weak var deleteButton: BounceButton!
    @IBOutlet private weak var walletInfoTableView: UITableView!

    private var chosenWalletIndex: Int {
        guard let index = AppCache.shared.chosenWalletIndex else {
            fatalError()
        }
        return index
    }

    private var selectedWallet: Wallet {
        WalletManager.shared.getWallet(at: chosenWalletIndex)
    }
    private var saveNavBarButton: UIBarButtonItem {
        UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(rightNavBarButtonTapped)
        )
    }
    private var cancelNavBarButton: UIBarButtonItem {
        UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(leftNavBarButtonTapped)
        )
    }
    private var dismissNavBarButton: UIBarButtonItem {
        UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(leftNavBarButtonTapped)
        )
    }
    private var editNavBarButton: UIBarButtonItem {
        UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(rightNavBarButtonTapped)
        )
    }
    private var leftBarButtonItem: UIBarButtonItem? {
        get { return navigationItem.leftBarButtonItem }
        set { navigationItem.leftBarButtonItem = newValue }
    }
    private var rightBarButtonItem: UIBarButtonItem? {
        get { return navigationItem.rightBarButtonItem }
        set { navigationItem.rightBarButtonItem = newValue }
    }
    private var isEditingWallet = false
    private var editMenuInteraction: UIEditMenuInteraction!
    private var selectedCellText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        walletInfoTableView.delegate = self
        walletInfoTableView.dataSource = self
        walletInfoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        walletInfoTableView.bounces = false
        setupInitialUI()

        editMenuInteraction = UIEditMenuInteraction(delegate: self)
        walletInfoTableView.addInteraction(editMenuInteraction)
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alert = UIAlertController.showDeleteConfirmationAlert(
            with: LocalizedKeys.alertTitle.localized,
            message: LocalizedKeys.alertMessage.localized
        ) {
            self.handleDeleteWallet()
        }
        present(alert, animated: true)
    }

    private func setupInitialUI() {
        walletNameTextField.backgroundColor = .clear
        walletNameTextField.borderStyle = .none
        walletNameTextField.text = selectedWallet.name
        walletNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        handleEditingWalletUI()

        textFieldView.layer.cornerRadius = 12.0
        textFieldView.backgroundColor = .secondarySystemGroupedBackground
        textFieldView.isHidden = true

    }

    @objc
    private func leftNavBarButtonTapped() {
        if isEditingWallet {
            isEditingWallet = false
            walletNameTextField.text = selectedWallet.name
            handleEditingWalletUI()
        } else {
            self.dismiss(animated: true)
        }
    }

    @objc
    private func rightNavBarButtonTapped() {
        Log.info("EDIT WALLET TAPPED GO TO EDIT WALLET VC")
        if isEditingWallet {
            Log.info("CHECK AND SAVE NEW WALLET INFO")
            guard let name = walletNameTextField.text else { return }
            if name == selectedWallet.name { return }
            if WalletManager.shared.checkNameDuplicate(name: name) {
                let alert = UIAlertController.showErrorAlert(message: "\(name) already exist")
                present(alert, animated: true)
                return
            }
            selectedWallet.modifyName(newName: name)
            Task {
                await FirestoreManager.modifyWalletName(wallet: selectedWallet, newName: name)
            }
            isEditingWallet = false
            NotificationCenter.default.post(
                name: K.NotificationName.didUpdateWalletName,
                object: nil
            )
        } else {
            isEditingWallet = true
        }
        handleEditingWalletUI()
    }

    @objc
    private func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        rightBarButtonItem?.isEnabled = !text.isEmpty
    }

    private func handleEditingWalletUI() {
        if isEditingWallet {
            leftBarButtonItem = cancelNavBarButton
            rightBarButtonItem = saveNavBarButton
            walletInfoTableView.fadeOut(withDuration: 0.2)
            deleteButton.fadeOut(withDuration: 0.2)
            walletNameTextField.isUserInteractionEnabled = true
            textFieldView.fadeIn(withDuration: 0.2)
        } else {
            leftBarButtonItem = dismissNavBarButton
            rightBarButtonItem = editNavBarButton
            walletInfoTableView.fadeIn(withDuration: 0.2)
            deleteButton.fadeIn(withDuration: 0.2)
            walletNameTextField.isUserInteractionEnabled = false
            walletNameTextField.resignFirstResponder()
            textFieldView.fadeOut(withDuration: 0.2)
        }
    }

    private func handleDeleteWallet() {
        Task {
            await FirestoreManager.deleteWallet(wallet: selectedWallet)
            if WalletManager.shared.removeWallet(at: chosenWalletIndex) {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(
                        name: K.NotificationName.didDeleteWallet,
                        object: nil
                    )
                }
            }
        }
    }
}

extension WalletInfoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)") else { return UITableViewCell() }
        guard let currentSection = WalletInfoTableSection(rawValue: indexPath.section) else { return cell }
        var content = cell.defaultContentConfiguration()
        switch currentSection {
        case .type:
            content.text = selectedWallet.type.getName()
        case .balance:
            content.text = selectedWallet.balance.toCurrencyString()
        case .dateCreated:
            content.text = selectedWallet.dateCreated.formatted(date: .long, time: .omitted)
        case .id:
            content.text = selectedWallet.id
            content.textProperties.font = .systemFont(ofSize: 12)
        }
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        WalletInfoTableSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let currentSection = WalletInfoTableSection(rawValue: section) else { return nil }
        return currentSection.getSectionName()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellText = tableView.cellForRow(at: indexPath)?.getText() ?? ""

        let rectForCellInTableView = tableView.rectForRow(at: indexPath)
        let location = CGPoint(x: rectForCellInTableView.origin.x + rectForCellInTableView.width / 2, y: rectForCellInTableView.origin.y)
        let configuration = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
        if let interaction = editMenuInteraction {
            interaction.presentEditMenu(with: configuration)
        }
    }
}

extension WalletInfoVC: UIEditMenuInteractionDelegate {
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        let menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Copy", handler: { _ in
                let pasteboard = UIPasteboard.general
                pasteboard.string = self.selectedCellText
            })
        ])
        return UIMenu(children: menu.children)
    }
}

private enum WalletInfoTableSection: Int, CaseIterable {
    case type, balance, dateCreated, id

    func getSectionName() -> String? {
        switch self {
        case .type:
            return LocalizedKeys.type.localized
        case .balance:
            return LocalizedKeys.balance.localized
        case .dateCreated:
            return LocalizedKeys.dateCreated.localized
        case .id:
            return LocalizedKeys.id.localized
        }
    }
}

private enum LocalizedKeys {
    static let title = "title"
    static let alertTitle = "alert_title"
    static let alertMessage = "alert_message"
    static let type = "type"
    static let balance = "balance"
    static let id = "id"
    static let dateCreated = "date_created"
}
