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
    @State private var retryWorkItem: DispatchWorkItem?  // Para cancelar el timer
    @State private var showOutsideRosarioAlert = false
    @State private var activeWeatherAlert: WeatherInfoAlert? = nil
    @State private var showInfoPrevSheet = false
    
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
                        
                        VStack(spacing: 0) {
                            // ── Título ──────────────────────────────────────
                            Text("MosquitoRisk")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(radius: 3)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, geo.size.height * 0.07)
                                .padding(.bottom, geo.size.height * 0.10)  // ← acerca riesgo al título 
                            
                            // ── Sección de riesgo (cerca del título) ─────────
                                if let _ = WViewModel.weather {
                                    VStack(spacing: 6) {
                                        Text("Riesgo de Mosquitos en tu Ubicación")
                                            .foregroundColor(.white.opacity(0.8))
                                            .font(.headline)
                                            .shadow(radius: 3)
                                        
                                        HStack(alignment: .center, spacing: 10) {
                                            Text(WViewModel.mosquitoRisk.rawValue)
                                                .font(.system(size: 64, weight: .thin))
                                                .foregroundColor(.white)
                                                .shadow(radius: 5)
                                            
                                            if WViewModel.isOutsideRosarioArea {
                                                Button {
                                                    showOutsideRosarioAlert = true
                                                } label: {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .font(.title2)
                                                        .foregroundColor(.yellow)
                                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .alert("Fuera del área de Rosario", isPresented: $showOutsideRosarioAlert) {
                                            Button("Entendido", role: .cancel) { }
                                        } message: {
                                            Text("Estás fuera del área de Rosario. El riesgo se calcula para tu ubicación actual, pero el mapa de calor muestra zonas de la ciudad de Rosario.")
                                        }
                                    }
                                }

                            
                            // Un Spacer para empujar el Título y el Riesgo hacia arriba
                            Spacer()
                        }
                        .frame(width: geo.size.width)
                        
                        // ── CAPA INFERIOR (Independiente: Celdas y botones) ──
                        VStack(spacing: 0) {
                            
                            // 👇 AJUSTA ESTE VALOR para mover las celdas y botones libremente
                            // Este número (0.45) es el % de pantalla desde arriba (45%).
                            // Como esto está en otra capa (VStack), moverlo NO afecta al título y al riesgo 🚀
                            Spacer(minLength: 0)
                                .frame(height: geo.size.height * 0.45)
                            
                            // ── Grid + mapa (anclados abajo) ─────────────────
                            VStack(spacing: geo.size.height * 0.022) {
                                if let weather = WViewModel.weather {
                                    // ── Celdas clima (fila horizontal) ──
                                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                                        Button { activeWeatherAlert = .temperatura } label: {
                                            CompactWeatherCard(icon: "thermometer", value: "\(Int(weather.temperature))°", label: "Temperatura")
                                        }
                                        .buttonStyle(.plain)
                                        Button { activeWeatherAlert = .humedad } label: {
                                            CompactWeatherCard(icon: "drop.fill", value: "\(Int(weather.humidity))%", label: "Humedad")
                                        }
                                        .buttonStyle(.plain)
                                        Button { activeWeatherAlert = .lluvia } label: {
                                            CompactWeatherCard(icon: "cloud.rain.fill", value: String(format: "%.0f mm", weather.precipitation), label: "Lluvia")
                                        }
                                        .buttonStyle(.plain)
                                        Button { activeWeatherAlert = .viento } label: {
                                            CompactWeatherCard(icon: "wind", value: String(format: "%.0f km/h", weather.windSpeed), label: "Viento")
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal)
                                    .alert(item: $activeWeatherAlert) { info in
                                        Alert(
                                            title: Text(info.title),
                                            message: Text(info.message),
                                            dismissButton: .default(Text("Entendido"))
                                        )
                                    }
                                    
                                    // ── Botón Mapa ──
                                    NavigationLink(destination: HeatMapView()) {
                                        GlassCardButton(
                                            icon: "map",
                                            title: "Mapa de Riesgo",
                                            subtitle: "Riesgo en Rosario",
                                            actionLabel: "Explorar"
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 16)
                                    
                                    // ── Botón Info & Prevención (unificado) ──
                                    Button { showInfoPrevSheet = true } label: {
                                        GlassCardButton(
                                            icon: "heart",
                                            title: "Info y Prevención",
                                            subtitle: "Aprende y protégete",
                                            actionLabel: "Ver más"
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 16)
                                    
                                } else {
                                    EmptyView()
                                }
                            }
                            
                            // Este Spacer ahora es flexible para empujar el contenido hacia arriba
                            Spacer()
                        }
                        .frame(width: geo.size.width)
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
        .sheet(isPresented: $showInfoPrevSheet) {
            InfoPrevSheet()
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

// MARK: - Celda compacta clima (HStack row)
struct CompactWeatherCard: View {
    let icon: String
    let value: String
    let label: String  // 👈 nuevo parámetro

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {  // 👈 icono + valor en horizontal
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))  // 👈 más grande
                    .foregroundColor(.white.opacity(0.85))

                Text(value)
                    .font(.system(size: 20, weight: .bold))  // 👈 más grande
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            Text(label)  // 👈 label debajo
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
    }
}
// MARK: - Reutilizable: tarjeta horizontal glassmorphism
struct GlassCardButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionLabel: String

    var body: some View {
        HStack(spacing: 16) {
            // Ícono circular
            ZStack {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 50, height: 50)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
            }

            // Texto
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                    .lineLimit(1)
            }

            Spacer()

            // Acción + flecha
            HStack(spacing: 4) {
                Text(actionLabel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .opacity(0.85)

                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
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
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}


// MARK: - Alert model para las celdas de clima
enum WeatherInfoAlert: String, Identifiable {
    case temperatura, humedad, lluvia, viento

    var id: String { rawValue }

    var title: String {
        switch self {
        case .temperatura: return "Temperatura"
        case .humedad:     return "Humedad"
        case .lluvia:      return "Lluvia"
        case .viento:      return "Viento"
        }
    }

    var message: String {
        switch self {
        case .temperatura:
            return "Los mosquitos son más activos entre 20°C y 30°C. Por debajo de 15°C su actividad cae drásticamente, y por encima de 35°C también se reduce. El rango ideal para su reproducción es entre 25°C y 28°C."
        case .humedad:
            return "La humedad alta (por encima del 60%) favorece la supervivencia de los mosquitos y acelera su ciclo de vida. Con humedad muy baja, los huevos se deshidratan y las larvas no prosperan."
        case .lluvia:
            return "Las lluvias crean charcos y recipientes con agua estancada, que son los criaderos preferidos del Aedes aegypti. Incluso lluvias leves acumuladas durante varios días elevan el riesgo significativamente."
        case .viento:
            return "El viento dificulta el vuelo de los mosquitos. Con vientos superiores a 10 km/h su actividad se reduce, y por encima de 20 km/h prácticamente no vuelan. Los días calmos y húmedos son los de mayor riesgo."
        }
    }
}
















