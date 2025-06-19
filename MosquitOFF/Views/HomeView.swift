
//  HomeView.swift
//  MosquitOFF

import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showMosquitoes = false
    @AppStorage("hasSeenIntro") private var hasSeenIntro: Bool = false
    @State private var showRiskInfo = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Fondo con gradiente
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    // Animación de mosquitos cuando el riesgo es alto o medio
                    if showMosquitoes && viewModel.mosquitoRisk != .low {
                        MosquitoAnimationView(riskLevel: viewModel.mosquitoRisk)
                            .transition(.opacity)
                    }

                    VStack(spacing: 25) {
                        // Título
                        Text("MosquitOFF")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 50)

                        Spacer()

                        // Datos del clima disponibles
                        if let weather = viewModel.weather {
                            VStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Text("Mosquito Risk")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.headline)

                                    Button(action: {
                                        showRiskInfo = true
                                    }) {
                                        Image(systemName: "info.circle")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .buttonStyle(.plain)
                                }

                                Text(viewModel.mosquitoRisk.rawValue)
                                    .font(.system(size: 64, weight: .thin))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, -20)

                            // Cuadrícula de datos climáticos
                            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                                WeatherInfoCard(icon: "thermometer", label: "Temp", value: "\(Int(weather.temperature))°")
                                WeatherInfoCard(icon: "drop.fill", label: "Humidity", value: "\(Int(weather.humidity))%")
                                WeatherInfoCard(icon: "cloud.rain.fill", label: "Rain", value: "\(String(format: "%.1f", weather.precipitation)) mm")
                                WeatherInfoCard(icon: "wind", label: "Wind", value: "\(String(format: "%.1f", weather.windSpeed)) km/h")
                            }
                            .padding(.horizontal)

                            // Botón al Heatmap
                            NavigationLink {
                                HeatMapView()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(Color.blue.opacity(0.2))
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 32))

                                    VStack(spacing: 6) {
                                        Image(systemName: "map.fill")
                                            .font(.title)
                                            .foregroundColor(.white)

                                        Text("View Mosquito Heatmap")
                                            .font(.headline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }
                                .frame(height: 220)
                                .padding(.horizontal)
                            }

                        } else {
                            // Indicador de carga mientras se obtiene el clima
                            ProgressView("Loading weather...")
                                .foregroundColor(.white)
                                .padding(.top, 40)
                        }

                        Spacer()
                    }
                    .frame(width: geo.size.width)
                }
                // Mostrar animación solo si el riesgo es alto o medio
                .onChange(of: viewModel.mosquitoRisk) { newRisk in
                    if newRisk != .low {
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
                // Sheet de introducción
                .sheet(isPresented: .constant(!hasSeenIntro)) {
                    IntroSheetView {
                        hasSeenIntro = true
                    }
                }
                // Sheet de información de riesgo
                .sheet(isPresented: $showRiskInfo) {
                    RiskInfoSheetView()
                }
            }
        }
    }
}











