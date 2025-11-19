//
//  Weather.swift
//  
//
//  Created by Astor Ludueña  on 19/06/2025.
//

import SwiftUI
import AVKit

struct WeatherVideoBackgroundView: UIViewRepresentable {
    let videoName: String

    class PlayerView: UIView {
        private var playerLayer: AVPlayerLayer?
        private var player: AVPlayer?
        
        override func layoutSubviews() {
            super.layoutSubviews()
            // NUEVO: Actualizar el frame cuando cambie el tamaño (rotación, iPad, etc.)
            playerLayer?.frame = bounds
        }

        func setupPlayer(with videoName: String) {
            guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else { return }

            let url = URL(fileURLWithPath: path)
            
            // NUEVO: Reutilizar player si ya existe, solo cambiar el video
            if player == nil {
                player = AVPlayer(url: url)
                player?.isMuted = true
                player?.actionAtItemEnd = .pause
                
                let layer = AVPlayerLayer(player: player)
                layer.videoGravity = .resizeAspectFill
                layer.frame = bounds  // 👈 CAMBIO: Usar bounds en lugar de UIScreen.main.bounds
                
                // Limpieza
                self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                
                self.layer.addSublayer(layer)
                self.playerLayer = layer
            } else {
                // Si el player ya existe, solo cambiar el item
                let newItem = AVPlayerItem(url: url)
                player?.replaceCurrentItem(with: newItem)
            }

            player?.seek(to: .zero)
            player?.play()
        }
        
        // NUEVO: Limpiar recursos cuando la vista se destruye
        deinit {
            player?.pause()
            player = nil
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
        }
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.setupPlayer(with: videoName)
        
        // NUEVO: Observar cambios de orientación
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            view.setNeedsLayout()
        }
        
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        // Siempre se vuelve a configurar cuando cambia el nombre
        uiView.setupPlayer(with: videoName)
    }
}
