//
//  LaunchScreenView.swift - Coordinada con WeatherViewModel
//

import SwiftUI

struct LaunchScreenView: View {
    @StateObject private var WViewModel = WeatherViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var isAnimating = false
    @State private var showMainApp = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var backgroundOpacity: Double = 0.0
    @State private var minimumTimeElapsed = false
    
    // Personalización de imagen
    let customImageName = "LaunchLogo" // Cambia por tu nombre de imagen
    let imageSize: CGFloat = 140 // Tamaño deseado
    let useRoundedCorners = false // true si quieres esquinas redondeadas
    let cornerRadius: CGFloat = 20 // Radio de esquinas si useRoundedCorners = true
    
    var body: some View {
        ZStack {
            // Fondo con gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(4),
                    Color.orange.opacity(4),
                    Color.green.opacity(4),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(backgroundOpacity)
            
            VStack {
                Spacer()
                
                // Imagen centrada
                ZStack {
                    // Efecto de resplandor
                    if isAnimating {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.4),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 100
                                )
                            )
                            .frame(width: imageSize * 1.5, height: imageSize * 1.5)
                            .opacity(logoOpacity * 0.6)
                            .scaleEffect(isAnimating ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                    }
                    
                    // Tu imagen personalizada
                    Group {
                        if useRoundedCorners {
                            Image(customImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageSize, height: imageSize)
                                .cornerRadius(cornerRadius)
                                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                        } else {
                            Image(customImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageSize, height: imageSize)
                                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                        }
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .rotation3DEffect(
                        .degrees(isAnimating ? 5 : 0),
                        axis: (x: 1.0, y: 1.0, z: 0.0)
                    )
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAdvancedAnimation()
            startMinimumTimer()
            // Agregar NetworkMonitor para detectar problemas de red
        }
        .onChange(of: shouldTransition) { ready in
            if ready && minimumTimeElapsed {
                transitionToMainApp()
            }
        }
        .onChange(of: minimumTimeElapsed) { elapsed in
            if elapsed && shouldTransition {
                transitionToMainApp()
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            HomeView()
        }
    }
    
    // Computed property para determinar si los datos están listos O si hay errores
    private var shouldTransition: Bool {
        // Transiciona si hay datos exitosos O si hay errores que manejar
        return WViewModel.weather != nil || hasLocationOrNetworkError
    }
    
    // Computed property para detectar errores de ubicación o red
    private var hasLocationOrNetworkError: Bool {
        let locationDenied = WViewModel.authorizationStatus == .denied || WViewModel.authorizationStatus == .restricted
        return locationDenied || !networkMonitor.isConnected
    }
    
    private func startMinimumTimer() {
        // Tiempo mínimo que debe mostrarse la launch screen (2.5 segundos)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            minimumTimeElapsed = true
        }
    }
    
    private func startAdvancedAnimation() {
        // 1. Background fade in
        withAnimation(.easeOut(duration: 0.8)) {
            backgroundOpacity = 1.0
        }
        
        // 2. Logo bounce in después de 0.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6, blendDuration: 0)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
        
        // 3. Animaciones continuas después de 1.0s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isAnimating = true
        }
    }
    
    private func transitionToMainApp() {
        // Transición más larga y suave para evitar parpadeos
        withAnimation(.easeInOut(duration: 1.2)) {
            logoScale = 0.9  // Reducción más sutil
            logoOpacity = 0.3  // No desaparecer completamente
        }
        
        // Delay más corto para superponer con el fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showMainApp = true
        }
        
        // Fade out final del background después de mostrar la app
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.8)) {
                backgroundOpacity = 0.0
            }
        }
    }
}
