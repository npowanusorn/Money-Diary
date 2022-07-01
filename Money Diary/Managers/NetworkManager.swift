//
//  NetworkManager.swift
//  Money Diary
//
//  Created by Nucha Powanusorn on 30/06/2022.
//

import Foundation
import Network

class NetworkManager {

    var isInternetAvailable: Bool {
        get {
            return _internetAvailable
        }
    }

    private var _internetAvailable: Bool = true

    static let shared = NetworkManager()

    private let monitor = NWPathMonitor()

    private func getInternetStatus() {
        monitor.pathUpdateHandler = { path in
            switch path.status {
            case .satisfied:
                self._internetAvailable = true
                Log.info("INTERNET AVAILABLE")
            default:
                self._internetAvailable = false
                Log.info("INTERNET NOT AVAILABLE")
            }
        }
        let queue = DispatchQueue(label: "monitor")
        monitor.start(queue: queue)
    }

    func startInternetCheck() { getInternetStatus() }
}
