//
//  BiometryManager.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 29/06/2022.
//

import Foundation
import LocalAuthentication

class BiometryManager {

    static let shared = BiometryManager()

    func checkBiometrics() -> NSError? {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return error }

        return nil
    }

    func logInWithBiometrics() async -> Error? {
        let context = LAContext()
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in with biometrics")
            UserDefaults.standard.set(true, forKey: K.UserDefaultsKeys.isBiometryEnabled)
            return nil
        } catch {
            return error
        }
    }
}
