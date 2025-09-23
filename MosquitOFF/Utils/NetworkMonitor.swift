//
//  NetworkMonitor.swift
//  MosquitOFF
//
//  Created by Astor Ludueña on 27/06/2025.
//

import Network
import Combine

class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

