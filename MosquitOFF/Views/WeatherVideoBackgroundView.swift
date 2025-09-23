//
//  Weather.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 19/06/2025.
//

import SwiftUI
import AVKit

struct WeatherVideoBackgroundView: UIViewRepresentable {
    let videoName: String

    class PlayerView: UIView {
        private var playerLayer: AVPlayerLayer?

        func setupPlayer(with videoName: String) {
            guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else { return }

            let url = URL(fileURLWithPath: path)
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.actionAtItemEnd = .pause // Se detiene al terminar

            let layer = AVPlayerLayer(player: player)
            layer.videoGravity = .resizeAspectFill
            layer.frame = UIScreen.main.bounds

            // Limpieza
            self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

            self.layer.addSublayer(layer)
            self.playerLayer = layer

            player.seek(to: .zero)
            player.play()
        }
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.setupPlayer(with: videoName)
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        // Siempre se vuelve a configurar cuando cambia el nombre
        uiView.setupPlayer(with: videoName)
    }
}

