//
//  HomeView+Preview.swift
//  MosquitOFF
//
//  Created by Astor Ludueña on 06/05/2025.//

import SwiftUI
import MapKit

struct MockHomeView: View {
    let mockWeather = WeatherData(
        temperature: 23,     // dentro del rango medium
            humidity: 100,        // dentro del rango medium
            condition: "Cloudy",
            precipitation: 10,
            windSpeed: 10        // suficientemente bajo para no reducir el riesgo
    )
    
    @State private var showMosquitoes = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
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

                        Spacer()
                        
                        VStack(spacing: 8) {
                            Text("Mosquito Risk")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.headline)
                            Text(riskLevel.rawValue)
                                .font(.system(size: 64, weight: .thin))
                                .foregroundColor(.white)
                        }
                        .padding(.top, -20)

                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                            WeatherInfoCard(icon: "thermometer", label: "Temp", value: "\(Int(mockWeather.temperature))°")
                            WeatherInfoCard(icon: "drop.fill", label: "Humidity", value: "\(Int(mockWeather.humidity))%")
                            WeatherInfoCard(icon: "cloud.rain.fill", label: "Rain", value: "\(String(format: "%.1f", mockWeather.precipitation)) mm")
                            WeatherInfoCard(icon: "wind", label: "Wind", value: "\(String(format: "%.1f", mockWeather.windSpeed)) km/h")
                        }
                        .padding(.horizontal)

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

struct WeatherInfoCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: 120)
        .padding()
        .background(.ultraThinMaterial)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(16)
    }
}

#Preview {
    MockHomeView()
}

















