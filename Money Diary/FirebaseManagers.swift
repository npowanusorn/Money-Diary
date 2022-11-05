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

    static func signIn(with email: String, password: String, viewController: UIViewController) async -> Bool {
        do {
            let keychain = KeychainSwift()
            Log.info("**** SIGNING IN ****")
            try await Auth.auth().signIn(withEmail: email, password: password)
            Log.info("**** SIGNED IN ****")
            keychain.set(email, forKey: K.KeychainKeys.emailKey)
            keychain.set(password, forKey: K.KeychainKeys.passwordKey)
            return true
        } catch {
            Log.error("ERROR SIGNING IN: \(error.localizedDescription)")
            FirebaseErrorManager.handleError(error: error as NSError, viewController: viewController)
            return false
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
            FirebaseErrorManager.handleError(error: error as NSError, viewController: viewController)
        }
    }
    
    static func deleteAccount(with password: String, viewController: UIViewController) async {
        let keychain = KeychainSwift()
        let currentUser = Auth.auth().currentUser
        guard let email = keychain.get(K.KeychainKeys.emailKey) else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            Log.info("**** REAUTHENTICATING ****")
            try await currentUser?.reauthenticate(with: credential)
            Log.info("**** REAUTHENTICATED - STARTING ACCOUNT DELETION ****")
            try await currentUser?.delete()
            Log.info("**** DELETION COMPLETE ****")
            clearAllData()
        } catch let error as NSError {
            Log.error("ERROR DELETING: \(error.localizedDescription)")
            FirebaseErrorManager.handleError(error: error, viewController: viewController)
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
            let walletSnapshot = try await walletCollection
                .order(by: K.FirestoreKeys.FieldKeys.dateCreated)
                .getDocuments()
            let walletDocuments = walletSnapshot.documents
            for walletDocument in walletDocuments {
                let walletName = (walletDocument.data()[K.FirestoreKeys.FieldKeys.name] as? String) ?? ""
                let walletBalance = (walletDocument.data()[K.FirestoreKeys.FieldKeys.balance] as? Double) ?? 0.0
                let walletID = (walletDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String) ?? generateUID()
                let walletTypeString = (walletDocument.data()[K.FirestoreKeys.FieldKeys.type] as? String) ?? "unknown"
                let walletType = WalletType(rawValue: walletTypeString) ?? .unknown
                let walletDateCreated = (walletDocument.data()[K.FirestoreKeys.FieldKeys.dateCreated] as? Timestamp)?.dateValue() ?? .distantPast
                let walletForSnapshot = Wallet(name: walletName, balance: walletBalance, type: walletType, dateCreated: walletDateCreated, id: walletID)
                let recordCollectionQuery = walletCollection
                    .document(walletDocument.documentID)
                    .collection(K.FirestoreKeys.CollectionKeys.records)
                    .order(by: K.FirestoreKeys.FieldKeys.date)
                let recordSnapshot = try await recordCollectionQuery.getDocuments()
                let recordDocuments = recordSnapshot.documents
                for recordDocument in recordDocuments {
                    let amount = (recordDocument.data()[K.FirestoreKeys.FieldKeys.amount] as? Double) ?? 0.0
                    let date = (recordDocument.data()[K.FirestoreKeys.FieldKeys.date] as? Timestamp)?.dateValue() ?? Date()
                    let isExpense = (recordDocument.data()[K.FirestoreKeys.FieldKeys.expense] as? Bool) ?? true
                    let note = (recordDocument.data()[K.FirestoreKeys.FieldKeys.note] as? String) ?? ""
                    let walletID = (recordDocument.data()[K.FirestoreKeys.FieldKeys.walletID] as? String) ?? K.unknownWalletID
                    let id = (recordDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String) ?? generateUID()
                    let record = Record(amount: amount, note: note, date: date, walletID: walletID, isExpense: isExpense, id: id)
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
            K.FirestoreKeys.FieldKeys.balance: newWallet.balance,
            K.FirestoreKeys.FieldKeys.id : newWallet.id,
            K.FirestoreKeys.FieldKeys.type : newWallet.type.rawValue,
            K.FirestoreKeys.FieldKeys.dateCreated : newWallet.dateCreated
        ]) { error in
            if let error = error {
                Log.error("ERROR WRITING WALLET: \(error)")
            }
        }
    }

    static func writeData(forRecord newRecord: Record) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let walletID = newRecord.walletID
        let walletCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.wallets)
        do {
            let walletDocuments = try await walletCollection.getDocuments().documents
            for walletDocument in walletDocuments {
                let walletName = (walletDocument.data()[K.FirestoreKeys.FieldKeys.name] as? String) ?? ""
                if walletName == WalletManager.shared.getWallet(by: walletID)?.name {
                    walletCollection.document(walletDocument.documentID)
                        .collection(K.FirestoreKeys.CollectionKeys.records)
                        .addDocument(data: [
                            K.FirestoreKeys.FieldKeys.amount : newRecord.amount,
                            K.FirestoreKeys.FieldKeys.date : Timestamp(date: newRecord.date),
                            K.FirestoreKeys.FieldKeys.expense : newRecord.isExpense,
                            K.FirestoreKeys.FieldKeys.note : newRecord.note ?? "",
                            K.FirestoreKeys.FieldKeys.walletID : newRecord.walletID,
                            K.FirestoreKeys.FieldKeys.id : newRecord.id
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
    
    static func deleteWallet(wallet: Wallet) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let walletCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.wallets)
        do {
            let walletDocuments = try await walletCollection.getDocuments().documents
            for walletDocument in walletDocuments {
                let walletID = (walletDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String) ?? K.unknownWalletID
                if walletID == wallet.id {
                    try await walletCollection.document(walletDocument.documentID).delete()
                }
            }
        } catch {
            Log.error("ERROR: \(error)")
        }
    }
    
    static func deleteRecord(record: Record) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let walletCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.wallets)
        do {
            let walletDocuments = try await walletCollection.getDocuments().documents
            for walletDocument in walletDocuments {
                let walletID = walletDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String ?? K.unknownWalletID
                if record.walletID == walletID {
                    let recordCollection = walletCollection
                        .document(walletDocument.documentID)
                        .collection(K.FirestoreKeys.CollectionKeys.records)
                    let recordDocuments = try await recordCollection.getDocuments().documents
                    for recordDocument in recordDocuments {
                        let recordID = recordDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String ?? K.unknownID
                        if recordID == record.id {
                            Log.info("ATTEMPTING TO DELETE RECORD")
                            try await recordCollection.document(recordDocument.documentID).delete()
                            Log.info("RECORD DELETED")
                        }
                    }
                }
            }
        } catch {
            Log.error("ERROR: \(error)")
        }
    }

    static func modifyWalletName(wallet: Wallet, newName: String) async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let walletCollection = db.collection(K.FirestoreKeys.CollectionKeys.users)
            .document(currentUser.uid)
            .collection(K.FirestoreKeys.CollectionKeys.wallets)
        do {
            let walletDocuments = try await walletCollection.getDocuments().documents
            for walletDocument in walletDocuments {
                let walletID = walletDocument.data()[K.FirestoreKeys.FieldKeys.id] as? String ?? K.unknownWalletID
                if walletID == wallet.id {
                    try await walletCollection.document(walletDocument.documentID).updateData([
                        K.FirestoreKeys.FieldKeys.name : newName
                    ])
                }
            }
        } catch {
            Log.error("ERROR: \(error)")
        }
    }
}

class FirebaseErrorManager {
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
