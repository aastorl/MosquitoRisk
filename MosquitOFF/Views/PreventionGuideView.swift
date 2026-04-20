//
//  PreventionGuideView.swift
//

import SwiftUI
import Lottie

// MARK: - Modelo de sección
struct PreventionSection: Identifiable {
    let id = UUID()
    let animation: String
    let title: String
    let body: String
}

// MARK: - Vista principal
struct PreventionGuideView: View {

    private let sections: [PreventionSection] = [
        PreventionSection(
            animation: "boy-spots-face",
            title: "Protegé tu piel",
            body: "Aplicá repelente en toda zona de piel expuesta. Reaplicá cada 2-4 horas al aire libre. Usá mangas largas y ropa clara al amanecer y anochecer, cuando los mosquitos son más activos. Instalá mosquiteros en puertas y ventanas."
        ),
        PreventionSection(
            animation: "boy-fever",
            title: "Conocé los síntomas",
            body: "El dengue, el zika y el chikungunya se transmiten por picadura de mosquito. Sus síntomas incluyen fiebre alta repentina, dolor de cabeza intenso, dolor detrás de los ojos, dolores musculares y articulares, y sarpullido en la piel. Pueden aparecer entre 4 y 10 días después de la picadura."
        ),
        PreventionSection(
            animation: "boy-vomit",
            title: "Acudí al médico",
            body: "Ante cualquier síntoma como fiebre, vómitos, mareos o manchas en la piel luego de una picadura, consultá a un médico lo antes posible. No te automediques y evitá el ibuprofeno o aspirina sin indicación médica. La atención temprana puede ser determinante."
        )
    ]

    var body: some View {
        ZStack {
            // ── Fondo degradado verde-amarillo-rojo (igual que el app) ──
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.13, green: 0.55, blue: 0.13), location: 0.0),
                    .init(color: Color(red: 0.75, green: 0.75, blue: 0.05), location: 0.5),
                    .init(color: Color(red: 0.72, green: 0.12, blue: 0.12), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Capa de material para suavizar el fondo
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.25)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // ── Encabezado ──────────────────────────────────────
                    VStack(spacing: 6) {
                        Text("¿Cómo Protegerme?")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.top, 48)
                            .foregroundColor(.white)
                    }

                    // ── Tarjetas ─────────────────────────────────────────
                    VStack(spacing: 12) {
                        ForEach(sections) { section in
                            PreventionCard(section: section)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
        }
        .navigationTitle("Prevención")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Tarjeta individual
struct PreventionCard: View {
    let section: PreventionSection

    var body: some View {
        HStack(alignment: .center, spacing: 14) {

            // Animación Lottie
            LottieView(animationName: section.animation, loopMode: .loop, speed: 1.0)
                .frame(width: 95, height: 95)

            // Texto
            VStack(alignment: .leading, spacing: 4) {
                Text(section.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(section.body)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)

                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.28), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationStack {
        PreventionGuideView()
    }
}
