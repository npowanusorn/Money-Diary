//
//  Constants.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-06-19.
//

import UIKit
import SwiftyBeaver

public var Log = SwiftyBeaver.self

//public var AppCache = [String : Any]()

enum K {
    enum NotificationName {
        static let didDeleteWallet = "didDeleteWallet"
        static let didUpdateWalletName = "didUpdateWalletName"
        static let didAddWallet = "didAddWallet"
    }

    enum FirestoreKeys {
        enum CollectionKeys {
            static let records = "records"
            static let wallets = "wallets"
            static let users = "users"
        }
        enum FieldKeys {
            static let balance = "balance"
            static let name = "name"
            static let amount = "amount"
            static let dateCreated = "dateCreated"
            static let date = "date"
            static let expense = "isExpense"
            static let note = "note"
            static let walletID = "walletID"
            static let id = "id"
            static let type = "type"
            static let currency = "currency"
        }
    }

    enum KeychainKeys {
        static let passwordKey = "passwordKey"
        static let emailKey = "emailKey"
    }

    enum UserDefaultsKeys {
        static let isLoggedIn = "isLoggedIn"
        static let isBiometryEnabled = "isBiometryEnabled"
        static let localAccount = "localAccount"
        static let hasCompletedOnboard = "hasCompleteOnboard"
        static let isNotFirstTimeAppLaunch = "isNotFirstTimeAppLaunch"
    }
    
    enum Fonts: String {
        case bold = "Bold"
        case regular = "Regular"
        case demiBold = "Demi Bold"
        case medium = "Medium"

        func getFont(size: CGFloat) -> UIFont {
            let font = UIFont(name: "Avenir Next \(self.rawValue)", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
            return font
        }
    }

    enum Cache {
        static let walletType = "walletType"
        static let selectedWallet = "selectedWallet"
    }
    
    static let unknownWalletID = "unknown wallet id"
    static let unknownID = "unknown id"
}

enum FilterOption: Int {
    case all = 0
    case expense
    case income
}

enum WalletType: String, CaseIterable {
    case cash, bank, credit, laundry, unknown

    func getName() -> String { self.rawValue.localized }
}

enum CurrencyType: String, CaseIterable {
    case USD, EUR, CAD, JPY, THB

    func getName() -> String { self.rawValue.localized }
    func getCurrencySign() -> String {
        switch self {
        case .USD, .CAD:
            return "$"
        case .EUR:
            return "€"
        case .JPY:
            return "¥"
        case .THB:
            return "฿"
        }
    }
}
