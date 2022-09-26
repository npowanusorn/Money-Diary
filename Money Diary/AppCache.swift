//
//  AppCache.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 2022-09-19.
//

import Foundation

class AppCache {
    static let shared = AppCache()

    var dictionary = [String : Any]()
    var chosenWalletIndex: Int?
    var walletType: WalletType?
    var selectedRecord: Record?
    var chosenCurrency: CurrencyType?
}
