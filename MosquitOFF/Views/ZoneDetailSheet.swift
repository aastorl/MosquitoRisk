//
//  ZoneDetailSheet.swift
//

import SwiftUI
internal import _LocationEssentials

struct ZoneDetailSheet: View {
    let zone: RiskZone

    private var riskColor: Color {
        switch zone.riskLevel {
        case .high:   return Color(red: 0.85, green: 0.15, blue: 0.15)
        case .medium: return Color(red: 0.90, green: 0.55, blue: 0.10)
        case .low:    return Color(red: 0.15, green: 0.65, blue: 0.25)
        }
    }

    private var riskLabel: String {
        switch zone.riskLevel {
        case .high:   return "Alto"
        case .medium: return "Medio"
        case .low:    return "Bajo"
        }
    }

    var body: some View {
        ZStack {
            // Fondo degradado según nivel de riesgo
            LinearGradient(
                colors: [riskColor.opacity(0.85), riskColor.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // ── Encabezado ──────────────────────────────────
                    VStack(spacing: 6) {
                        Image(systemName: zone.name.contains("Isla") || zone.name.contains("Banquito") || zone.name.contains("Paraná") ? "beach.umbrella.fill" : "tree.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .shadow(radius: 4)

                        Text(zone.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(radius: 3)

                        Text("Riesgo: \(riskLabel)")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 32)

                    // ── Parámetros climáticos ────────────────────────
                    if let w = zone.weather {
                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 12),
                                      GridItem(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            WeatherInfoCard(icon: "thermometer",
                                            label: "Temperatura",
                                            value: "\(Int(w.temperature))°C")
                            WeatherInfoCard(icon: "drop.fill",
                                            label: "Humedad",
                                            value: "\(Int(w.humidity))%")
                            WeatherInfoCard(icon: "cloud.rain.fill",
                                            label: "Lluvia",
                                            value: String(format: "%.1f mm", w.precipitation))
                            WeatherInfoCard(icon: "wind",
                                            label: "Viento",
                                            value: String(format: "%.1f km/h", w.windSpeed))
                        }
                        .padding(.horizontal, 16)
                    } else {
                        Text("Datos climáticos no disponibles")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.subheadline)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.bottom, 48)
            }
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(24)
    }
}

// MARK: - Fila de parámetro
struct ZoneParamRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28)
                .shadow(color: .black.opacity(0.3), radius: 2)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .opacity(0.75)
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ZoneDetailSheet(zone: RiskZone(
        coordinate: .init(latitude: -32.95, longitude: -60.65),
        riskLevel: .medium,
        name: "Parque Urquiza",
        weather: WeatherData(
            temperature: 26, humidity: 72,
            condition: "Cloudy", precipitation: 3.2,
            windSpeed: 8.5,
            sunrise: Date(), sunset: Date()
        )
    ))
}
