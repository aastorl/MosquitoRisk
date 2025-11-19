//
//  HomeView.swift
//  
//

import SwiftUI
import MapKit
internal import CoreLocation
import Combine

struct HomeView: View {
    @StateObject private var WViewModel = WeatherViewModel()
    @State private var showMosquitoes = false
    @AppStorage("hasSeenIntro") private var hasSeenIntro: Bool = false
    @State private var showRiskInfo = false
    @State private var showFallbackView = false
    @State private var showLocationDeniedView = false
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var retryWorkItem: DispatchWorkItem?  // 👈 NUEVO: Para cancelar el timer
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // PANTALLAS DE ERROR CON BACKGROUND FULLSCREEN
                    if showLocationDeniedView {
                        // Pantalla error ubicación - FULLSCREEN
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.red.opacity(4),
                                    Color.orange.opacity(4),
                                    Color.green.opacity(4),
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea(.all)
                            
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .ignoresSafeArea(.all)
                            
                            VStack(spacing: 20) {
                                Spacer()
                                
                                Image(systemName: "location.slash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.orange)
                                    .shadow(radius: 2)
                                
                                VStack(spacing: 12) {
                                    Text("Permisos de ubicación denegados")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .shadow(radius: 1)
                                    
                                    Text("MosquitoRisk necesita tu ubicación para evaluar el riesgo de mosquitos en tu zona.")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                        .shadow(radius: 1)
                                }
                                .padding(.horizontal, 32)
                                
                                Button {
                                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(appSettings)
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "gear")
                                        Text("Ir a Configuración")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .shadow(radius: 8)
                                }
                                .padding(.top, 8)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    else if showFallbackView || WViewModel.hasNetworkError {
                        // 👆 CAMBIO: Agregar condición hasNetworkError
                        // Pantalla error sin internet - FULLSCREEN
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.red.opacity(4),
                                    Color.orange.opacity(4),
                                    Color.green.opacity(4),
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea(.all)
                            
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .ignoresSafeArea(.all)
                            
                            VStack(spacing: 20) {
                                Spacer()
                                
                                Image(systemName: "wifi.slash")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.red)
                                    .shadow(radius: 2)
                                
                                VStack(spacing: 12) {
                                    Text("Sin conexión a internet")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .shadow(radius: 1)
                                    
                                    Text("No pudimos obtener los datos del clima. Revisa tu conexión a internet e intentá nuevamente.")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(nil)
                                        .shadow(radius: 1)
                                }
                                .padding(.horizontal, 32)
                                
                                Button {
                                    // 👇 CAMBIO: Cancelar timer anterior y crear uno nuevo
                                    retryWorkItem?.cancel()
                                    showFallbackView = false
                                    WViewModel.retryFetch()
                                    
                                    // Nuevo timer de 8 segundos
                                    let workItem = DispatchWorkItem {
                                        if WViewModel.weather == nil && !showLocationDeniedView {
                                            showFallbackView = true
                                        }
                                    }
                                    retryWorkItem = workItem
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: workItem)
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Reintentar")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    .shadow(radius: 8)
                                }
                                .padding(.top, 8)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    else {
                        // PANTALLA PRINCIPAL
                        if let _ = WViewModel.weather?.condition {
                            WeatherVideoBackgroundView(videoName: WViewModel.weatherVideoName)
                                .ignoresSafeArea()
                                .allowsHitTesting(false)
                        }
                        
                        if showMosquitoes && WViewModel.mosquitoRisk != .low {
                            MosquitoAnimationView(riskLevel: WViewModel.mosquitoRisk)
                                .transition(.opacity)
                        }
                        
                        VStack(spacing: 25) {
                            Text("MosquitoRisk")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 50)
                                .shadow(radius: 3)
                            
                            Spacer()
                            
                            VStack {
                                if let weather = WViewModel.weather {
                                    VStack(spacing: 8) {
                                        HStack(spacing: 6) {
                                            Text("Riesgo de Mosquitos en tu Ubicación")
                                                .foregroundColor(.white.opacity(0.8))
                                                .font(.headline)
                                                .shadow(radius: 3)
                                            
                                            Button {
                                                showRiskInfo = true
                                            } label: {
                                                Image(systemName: "info.circle")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        
                                        Text(WViewModel.mosquitoRisk.rawValue)
                                            .font(.system(size: 64, weight: .thin))
                                            .foregroundColor(.white)
                                            .shadow(radius: 5)
                                    }
                                    .padding(.top, -20)
                                    
                                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                                        WeatherInfoCard(icon: "thermometer", label: "Temperatura", value: "\(Int(weather.temperature))°")
                                        WeatherInfoCard(icon: "drop.fill", label: "Humedad", value: "\(Int(weather.humidity))%")
                                        WeatherInfoCard(icon: "cloud.rain.fill", label: "Lluvia", value: "\(String(format: "%.1f", weather.precipitation)) mm")
                                        WeatherInfoCard(icon: "wind", label: "Viento", value: "\(String(format: "%.1f", weather.windSpeed)) km/h")
                                    }
                                    .padding(.horizontal)
                                    
                                    // BOTÓN DE MAPA
                                    NavigationLink(destination: HeatMapView()) {
                                        ZStack {
                                            MiniHeatMapPreview()
                                                .frame(height: 200)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .opacity(0.1)
                                            
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(.ultraThinMaterial)
                                                .opacity(0.85)
                                            
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.black.opacity(0.3),
                                                            Color.clear,
                                                            Color.black.opacity(0.4)
                                                        ]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                            
                                            VStack(spacing: 20) {
                                                ZStack {
                                                    Circle()
                                                        .fill(.regularMaterial)
                                                        .frame(width: 56, height: 56)
                                                    
                                                    Circle()
                                                        .fill(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [
                                                                    Color.white.opacity(0.2),
                                                                    Color.clear
                                                                ]),
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                        .frame(width: 56, height: 56)
                                                    
                                                    Image(systemName: "map.fill")
                                                        .font(.system(size: 22, weight: .semibold))
                                                        .foregroundColor(.white)
                                                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                                }
                                                
                                                VStack(spacing: 12) {
                                                    VStack(spacing: 4) {
                                                        Text("Mapa de Riesgo")
                                                            .font(.title3)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white)
                                                            .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                                                        
                                                        Text("Parques y zonas de Rosario")
                                                            .font(.subheadline)
                                                            .foregroundColor(.white.opacity(0.9))
                                                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                                                    }
                                                    
                                                    HStack(spacing: 8) {
                                                        Text("Explorar mapa")
                                                            .font(.callout)
                                                            .fontWeight(.medium)
                                                            .foregroundColor(.white)
                                                        
                                                        Image(systemName: "arrow.right")
                                                            .font(.callout)
                                                            .fontWeight(.medium)
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                            }
                                            .padding(.vertical, 24)
                                        }
                                        .frame(height: 200)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.white.opacity(0.3),
                                                            Color.white.opacity(0.1)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 8)
                                } else {
                                    EmptyView()
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(width: geo.size.width)
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                    }
                }
                .onAppear {
                    let status = CLLocationManager.authorizationStatus()
                    updateViewsBasedOnStatus(status)
                    
                    if !networkMonitor.isConnected {
                        showFallbackView = true
                    }
                    
                    // 👇 CAMBIO: Usar DispatchWorkItem para poder cancelarlo
                    let workItem = DispatchWorkItem {
                        if WViewModel.weather == nil && !showLocationDeniedView {
                            showFallbackView = true
                        }
                    }
                    retryWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: workItem)
                }
                .onChange(of: WViewModel.authorizationStatus) { newStatus in
                    updateViewsBasedOnStatus(newStatus)
                }
                .onChange(of: networkMonitor.isConnected) { isConnected in
                    if !isConnected {
                        showFallbackView = true
                        showLocationDeniedView = false
                    } else {
                        showFallbackView = false
                        
                        if !isLocationDenied() {
                            WViewModel.retryFetch()
                        }
                    }
                }
                .onChange(of: WViewModel.hasNetworkError) { hasError in
                    // NUEVO: Detectar errores HTTP
                    if hasError {
                        showFallbackView = true
                    }
                }
                .onChange(of: WViewModel.mosquitoRisk) { newRisk in
                    if newRisk != .low {
                        withAnimation(.easeIn(duration: 1.0)) {
                            showMosquitoes = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                            withAnimation {
                                showMosquitoes = false
                            }
                        }
                    }
                }
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    let status = CLLocationManager.authorizationStatus()
                    updateViewsBasedOnStatus(status)
                }
            }
        }
        .sheet(isPresented: .constant(!hasSeenIntro)) {
            IntroSheetView {
                hasSeenIntro = true
            }
            .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $showRiskInfo) {
            RiskInfoSheetView()
        }
    }
    
    private func isLocationDenied() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .denied || status == .restricted
    }
    
    private func updateViewsBasedOnStatus(_ status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            showLocationDeniedView = true
            showFallbackView = false
        } else {
            showLocationDeniedView = false
            
            if !networkMonitor.isConnected {
                showFallbackView = true
            }
        }
    }
}

struct WeatherInfoCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: 120)
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.7)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: .black.opacity(0.2),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

















