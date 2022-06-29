//
//  FirebaseManagers.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 28/06/2022.
//

import Foundation
import Firebase
import KeychainSwift

// MARK: - Auth
class AuthManager {
    static func signIn(with email: String, password: String) async -> Error? {
        do {
            let keychain = KeychainSwift()
            Log.info("**** SIGNING IN ****")
            try await Auth.auth().signIn(withEmail: email, password: password)
            Log.info("**** SIGNED IN ****")
            keychain.set(email, forKey: "emailKey")
            keychain.set(password, forKey: "passwordKey")
            return nil
        } catch {
            Log.error("ERROR SIGNING IN: \(error.localizedDescription)")
            return error
        }
    }

    static func createUser(with email: String, password: String) async -> Error? {
        do {
            let keychain = KeychainSwift()
            Log.info("**** CREATING USER ****")
            try await Auth.auth().createUser(withEmail: email, password: password)
            Log.info("**** CREATED USER ****")
            keychain.set(email, forKey: "emailKey")
            keychain.set(password, forKey: "passwordKey")
            return nil
        } catch {
            Log.error("ERROR CREATING USER: \(error.localizedDescription)")
            return error
        }
    }
}

// MARK: - Firestore
class FirestoreManager {
    static func getData() async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let walletManager = WalletManager.shared
        let walletCollection = db.collection("users").document(currentUser.uid).collection("wallets")
        do {
            let walletSnapshot = try await walletCollection.getDocuments()
            let walletDocuments = walletSnapshot.documents
            for walletDocument in walletDocuments {
                let walletName = (walletDocument.data()["name"] as? String) ?? ""
                let walletBalance = (walletDocument.data()["balance"] as? Double) ?? 0.0
                let walletForSnapshot = Wallet(name: walletName, balance: walletBalance)
                let recordCollection = walletCollection.document(walletDocument.documentID).collection("records")
                let recordSnapshot = try await recordCollection.getDocuments()
                let recordDocuments = recordSnapshot.documents
                for recordDocument in recordDocuments {
                    let amount = (recordDocument.data()["amount"] as? Double) ?? 0.0
                    let date = (recordDocument.data()["date"] as? Timestamp)?.dateValue() ?? Date()
                    let isExpense = (recordDocument.data()["isExpense"] as? Bool) ?? true
                    let note = (recordDocument.data()["note"] as? String) ?? ""
                    let wallet = (recordDocument.data()["wallet"] as? Int) ?? 0
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
        // TODO
    }

    static func writeData(forRecord newRecord: Record) async {
        // TODO
    }
}
