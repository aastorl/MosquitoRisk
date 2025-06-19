import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Permiso

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Notification permission error: \(error.localizedDescription)")
                } else if granted {
                    print("✅ Notification permission granted")
                    self.setupNotificationCategories()
                } else {
                    print("❌ Notification permission denied")
                }
            }
        }
    }

    // MARK: - Categorías y acciones

    private func setupNotificationCategories() {
        let reportAction = UNNotificationAction(identifier: "REPORT_MOSQUITO_ACTION",
                                                title: "Report Mosquito",
                                                options: [.foreground])
        let category = UNNotificationCategory(identifier: "DENGUE_RISK_CATEGORY",
                                              actions: [reportAction],
                                              intentIdentifiers: [],
                                              options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - Notificación solo si el riesgo es alto

    func sendDengueRiskNotificationIfHigh(riskLevel: MosquitoRisk.RiskLevel) {
        guard riskLevel == .high else {
            print("ℹ️ Risk level is not high, no notification sent.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "⚠️ Dengue Risk Alert"
        content.body = "Weather conditions indicate high mosquito activity in your area. Please take precautions."
        content.sound = .default
        content.categoryIdentifier = "DENGUE_RISK_CATEGORY"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: "dengueRiskAlert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling dengue notification: \(error.localizedDescription)")
            } else {
                print("📢 Dengue risk notification (HIGH) scheduled")
            }
        }
    }

    // MARK: - Eliminar todas las notificaciones

    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("🔕 All notifications removed")
    }
}



