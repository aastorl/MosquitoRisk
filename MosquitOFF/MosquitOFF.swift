//
//  MosquitOFF.swift
//
//  Created by Astor Ludueña  on 05/05/2025.
//

import SwiftUI
import AVFoundation

@main
struct MosquitOFF: App {
    init() {
        // Evita que la app pause la música externa al iniciarse
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
        }
    }
}

