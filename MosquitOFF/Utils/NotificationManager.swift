import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    // MARK: - Propiedades para throttling
    private var lastRiskLevel: MosquitoRisk.RiskLevel?
    private var lastNotificationTime: Date?
    
    private init() {}

    // MARK: - Solicitar permiso de notificaciones

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error al solicitar permiso: \(error.localizedDescription)")
                } else if granted {
                    print("Permiso concedido")
                    self.setupNotificationCategories()
                } else {
                    print("Permiso denegado por el usuario")
                }
            }
        }
    }

    // MARK: - Configurar categorías (sin acciones innecesarias)

    private func setupNotificationCategories() {
        let dengueCategory = UNNotificationCategory(
            identifier: "MOSQUITO_RISK_CATEGORY",
            actions: [], // Eliminamos la acción que no funcionaba
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([dengueCategory])
    }

    // MARK: - Verificar permisos del sistema (método auxiliar)
    
    private func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    // MARK: - Enviar notificación solo para riesgo alto

    func sendMosquitoRiskNotification(riskLevel: MosquitoRisk.RiskLevel, weather: WeatherData) {
        // Solo procesar cambios significativos
        if let lastLevel = lastRiskLevel, lastLevel == riskLevel {
            return
        }
        
        lastRiskLevel = riskLevel
        let now = Date()
        
        // Solo notificar cuando el riesgo es alto
        guard riskLevel == .high else {
            print("ℹ️ Riesgo actualizado: \(riskLevel.rawValue)")
            return
        }
        
        // Throttling: 30 minutos entre notificaciones
        if let lastTime = lastNotificationTime {
            let timeSinceLastNotification = now.timeIntervalSince(lastTime)
            guard timeSinceLastNotification > 1800 else { // 30 minutos = 1800 segundos
                print("Notificación ya enviada hace poco. Esperando...")
                return
            }
        }

        checkNotificationPermission { [weak self] isAuthorized in
            guard isAuthorized else {
                print("Notificaciones no autorizadas en el sistema")
                return
            }
            
            self?.scheduleHighRiskNotification(weather: weather)
            self?.lastNotificationTime = now
        }
    }
    
    // MARK: - Programar notificación solo para riesgo alto
    
    private func scheduleHighRiskNotification(weather: WeatherData) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["mosquitoRiskAlert"])
        
        let content = UNMutableNotificationContent()
        content.title = "Riesgo alto de mosquitos"
        content.body = createHighRiskMessage(weather: weather)
        content.sound = .default
        content.categoryIdentifier = "MOSQUITO_RISK_CATEGORY"

        // Notificación inmediata
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "mosquitoRiskAlert",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al agendar notificación: \(error.localizedDescription)")
            } else {
                print("Notificación de riesgo alto programada")
            }
        }
    }
    
    // MARK: - Crear mensaje contextual para riesgo alto
    
    private func createHighRiskMessage(weather: WeatherData) -> String {
        var factors: [String] = []
        
        // Identificar factores de riesgo específicos
        if weather.humidity > 70 {
            factors.append("humedad alta (\(Int(weather.humidity))%)")
        }
        
        if weather.temperature > 25 {
            factors.append("temperatura elevada (\(Int(weather.temperature))°)")
        }
        
        if weather.precipitation > 0 {
            factors.append("lluvia reciente")
        }
        
        let baseMessage = "Condiciones propicias para mosquitos en tu zona."
        
        if factors.isEmpty {
            return baseMessage + " Tomá precauciones."
        } else {
            let factorsList = factors.joined(separator: ", ")
            return baseMessage + " Factores: \(factorsList). Usá repelente y evitá agua estancada."
        }
    }

    // MARK: - Eliminar todas las notificaciones

    func removeAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        print("Todas las notificaciones eliminadas")
    }
    
}



