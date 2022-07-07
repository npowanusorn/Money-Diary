//
//  FirebaseManagers.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 28/06/2022.
//

import Foundation
import Firebase
import KeychainSwift
import UIKit

// MARK: - Auth
class AuthManager {
    static func signIn(with email: String, password: String) async -> Error? {
        do {
            let keychain = KeychainSwift()
            Log.info("**** SIGNING IN ****")
            try await Auth.auth().signIn(withEmail: email, password: password)
            Log.info("**** SIGNED IN ****")
            keychain.set(email, forKey: K.KeychainKeys.emailKey)
            keychain.set(password, forKey: K.KeychainKeys.passwordKey)
            return nil
        } catch {
            Log.error("ERROR SIGNING IN: \(error.localizedDescription)")
            return error
        }
    }

    static func signIn(with email: String, password: String, viewController: UIViewController) async {
        do {
            let keychain = KeychainSwift()
            Log.info("**** SIGNING IN ****")
            try await Auth.auth().signIn(withEmail: email, password: password)
            Log.info("**** SIGNED IN ****")
            keychain.set(email, forKey: K.KeychainKeys.emailKey)
            keychain.set(password, forKey: K.KeychainKeys.passwordKey)
        } catch {
            Log.error("ERROR SIGNING IN: \(error.localizedDescription)")
            FIRErrorManager.handleError(error: error as NSError, viewController: viewController)
        }
    }

    static func createUser(with email: String, password: String, viewController: UIViewController) async {
        do {
            let keychain = KeychainSwift()
            Log.info("**** CREATING USER ****")
            try await Auth.auth().createUser(withEmail: email, password: password)
            Log.info("**** CREATED USER ****")
            keychain.set(email, forKey: K.KeychainKeys.emailKey)
            keychain.set(password, forKey: K.KeychainKeys.passwordKey)
        } catch {
            Log.error("ERROR CREATING USER: \(error.localizedDescription)")
            FIRErrorManager.handleError(error: error as NSError, viewController: viewController)
        }
    }
}

// MARK: - Firestore
class FirestoreManager {
    static func getData() async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let walletManager = WalletManager.shared
        let walletCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.wallets)
        do {
            let walletSnapshot = try await walletCollection.getDocuments()
            let walletDocuments = walletSnapshot.documents
            for walletDocument in walletDocuments {
                let walletName = (walletDocument.data()[K.FirestoreKeys.FieldKeys.name] as? String) ?? ""
                let walletBalance = (walletDocument.data()[K.FirestoreKeys.FieldKeys.balance] as? Double) ?? 0.0
                let walletForSnapshot = Wallet(name: walletName, balance: walletBalance)
                let recordCollection = walletCollection
                    .document(walletDocument.documentID)
                    .collection(K.FirestoreKeys.CollectionKeys.records)
                let recordSnapshot = try await recordCollection.getDocuments()
                let recordDocuments = recordSnapshot.documents
                for recordDocument in recordDocuments {
                    let amount = (recordDocument.data()[K.FirestoreKeys.FieldKeys.amount] as? Double) ?? 0.0
                    let date = (recordDocument.data()[K.FirestoreKeys.FieldKeys.date] as? Timestamp)?.dateValue() ?? Date()
                    let isExpense = (recordDocument.data()[K.FirestoreKeys.FieldKeys.expense] as? Bool) ?? true
                    let note = (recordDocument.data()[K.FirestoreKeys.FieldKeys.note] as? String) ?? ""
                    let wallet = (recordDocument.data()[K.FirestoreKeys.FieldKeys.wallet] as? Int) ?? 0
                    let record = Record(amount: amount, note: note, date: date, wallet: wallet, isExpense: isExpense)
                    walletForSnapshot.addRecord(newRecord: record)
                }
                walletManager.addWallet(newWallet: walletForSnapshot)
            }
        } catch {
            Log.error("ERROR GETTING DATA: \(error.localizedDescription)")
        }
    }

    static func writeData(forWallet newWallet: Wallet) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let walletCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.wallets)
        walletCollection.addDocument(data: [
            K.FirestoreKeys.FieldKeys.name : newWallet.name,
            K.FirestoreKeys.FieldKeys.balance: newWallet.balance
        ]) { error in
            if let error = error {
                Log.error("ERROR WRITING WALLET: \(error)")
            }
        }
    }

    static func writeData(forRecord newRecord: Record) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let wallet = newRecord.wallet
        let walletCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.wallets)
        do {
            let walletDocuments = try await walletCollection.getDocuments().documents
            for walletDocument in walletDocuments {
                let walletName = (walletDocument.data()[K.FirestoreKeys.FieldKeys.name] as? String) ?? ""
                if walletName == WalletManager.shared.getWallet(at: wallet).name {
                    walletCollection.document(walletDocument.documentID)
                        .collection(K.FirestoreKeys.CollectionKeys.records)
                        .addDocument(data: [
                            K.FirestoreKeys.FieldKeys.amount : newRecord.amount,
                            K.FirestoreKeys.FieldKeys.date : Timestamp(date: newRecord.date),
                            K.FirestoreKeys.FieldKeys.expense : newRecord.isExpense,
                            K.FirestoreKeys.FieldKeys.note : newRecord.note ?? "",
                            K.FirestoreKeys.FieldKeys.wallet : newRecord.wallet,
                        ]) { error in
                            if let error = error {
                                Log.error("ERROR: \(error)")
                            }
                        }
                }
            }
        } catch {
            Log.error("ERROR: \(error)")
        }
    }
}

class FIRErrorManager {
    static func handleError(error: NSError, viewController: UIViewController) {
        var errorMessage = ""

        switch error.code {
        case AuthErrorCode.networkError.rawValue:
            errorMessage = "No internet connection available"
        case
            AuthErrorCode.userNotFound.rawValue,
            AuthErrorCode.wrongPassword.rawValue:
            errorMessage = "Email or password is incorrect"
        case AuthErrorCode.userDisabled.rawValue:
            errorMessage = "Account is disabled"
        case AuthErrorCode.weakPassword.rawValue:
            errorMessage = "Password must be at least 6 characters long"
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            errorMessage = "Email already in use. Sign in or use a different email"
        default:
            errorMessage = "Unknown error, try again later. \nError code: \(error.code)"
        }
        let alert = UIAlertController.showErrorAlert(message: errorMessage)
        main { viewController.present(alert, animated: true) }
    }
}
