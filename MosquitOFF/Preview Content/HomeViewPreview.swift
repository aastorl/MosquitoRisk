//
//  HomeView+Preview.swift
//  MosquitOFF
//
//  Created by Astor Ludueña on 06/05/2025.//


import SwiftUI
import MapKit

// Preview normal con datos mock
struct MockHomeView: View {
    let mockWeather = WeatherData(
        temperature: 23,                // dentro del rango medium
        humidity: 100,                  // dentro del rango medium
        condition: "Cloudy",
        precipitation: 10,
        windSpeed: 10,                  // suficientemente bajo para no reducir el riesgo
        sunrise: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date(),
        sunset: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
    )

    @State private var showMosquitoes = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Fondo simulado con gradiente (sin video en mock)
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    let riskLevel = MosquitoRisk.calculateRisk(from: mockWeather)
                    if showMosquitoes && riskLevel != .low {
                        MosquitoAnimationView(riskLevel: riskLevel)
                            .transition(.opacity)
                    }

                    VStack(spacing: 25) {
                        Text("MosquitOFF")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 50)
                            .shadow(radius: 3)

                        Spacer()
                        
                        VStack { // Contenedor centrado
                            VStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Text("Riesgo de Mosquitos")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.headline)
                                        .shadow(radius: 3)
                                    
                                    Button {
                                        // Action for mock
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                Text(riskLevel.rawValue)
                                    .font(.system(size: 64, weight: .thin))
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                            }
                            .padding(.top, -20)

                            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                                WeatherInfoCard(icon: "thermometer", label: "Temperatura", value: "\(Int(mockWeather.temperature))°")
                                WeatherInfoCard(icon: "drop.fill", label: "Humedad", value: "\(Int(mockWeather.humidity))%")
                                WeatherInfoCard(icon: "cloud.rain.fill", label: "Lluvia", value: "\(String(format: "%.1f", mockWeather.precipitation)) mm")
                                WeatherInfoCard(icon: "wind", label: "Viento", value: "\(String(format: "%.1f", mockWeather.windSpeed)) km/h")
                            }
                            .padding(.horizontal)

                            NavigationLink(destination: HeatMapView()) {
                                ZStack {
                                    // Simulando MiniHeatMapPreview con un rectángulo
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(height: 225)
                                        .overlay(
                                            VStack(spacing: 6) {
                                                Image(systemName: "map.fill")
                                                    .font(.title)
                                                    .foregroundColor(.white.opacity(0.8))
                                                Text("Mapa simulado")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }
                                        )
                                    
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Color.black.opacity(0.1)
                                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                        )
                                        .frame(height: 225)
                                    
                                    Text("Ver mapa de riesgo")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .shadow(radius: 4)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(radius: 0)
                                .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 8)
                        }

                        Spacer()
                    }
                    .frame(width: geo.size.width)
                }
                .onAppear {
                    let riskLevel = MosquitoRisk.calculateRisk(from: mockWeather)
                    if riskLevel != .low {
                        withAnimation(.easeIn(duration: 1.0)) {
                            showMosquitoes = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            withAnimation {
                                showMosquitoes = false
                            }
                        }
                    }
                }
            }
        }
    }
}

// Preview para estados de error
struct HomeViewWithError: View {
    enum ErrorType {
        case internet, location
    }
    
    let errorType: ErrorType
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Fondo similar al HomeView
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 25) {
                        Text("MosquitOFF")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 50)
                            .shadow(radius: 3)
                        
                        Spacer()
                        
                        VStack {  // Contenedor centrado para los errores
                            if errorType == .location {
                                // Vista específica para ubicación denegada
                                VStack(spacing: 20) {
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
                                        
                                        Text("MosquitOFF necesita tu ubicación para evaluar el riesgo de mosquitos en tu zona.")
                                            .font(.body)
                                            .foregroundColor(.white.opacity(0.9))
                                            .multilineTextAlignment(.center)
                                            .lineLimit(nil)
                                            .shadow(radius: 1)
                                    }
                                    .padding(.horizontal, 32)
                                    
                                    Button {
                                        // Acción para preview
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
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                                .shadow(radius: 10)
                                
                            } else {
                                // Vista específica para sin internet
                                VStack(spacing: 20) {
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
                                        // Acción para preview
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
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                                .shadow(radius: 10)
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(width: geo.size.width)
                }
            }
        }
    }
}

#Preview("Normal") {
    MockHomeView()
}

#Preview("Error de Internet") {
    HomeViewWithError(errorType: .internet)
}

#Preview("Error de Ubicación") {
    HomeViewWithError(errorType: .location)
}

















