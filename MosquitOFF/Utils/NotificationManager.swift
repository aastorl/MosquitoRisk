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

    // MARK: - Notificaciones

    func sendDengueRiskNotification(after seconds: TimeInterval = 10) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Dengue Risk Alert"
        content.body = "Weather conditions increase mosquito activity in your area. Please take precautions and report any sightings."
        content.sound = .default
        content.categoryIdentifier = "DENGUE_RISK_CATEGORY"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "dengueRiskAlert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling dengue notification: \(error.localizedDescription)")
            } else {
                print("📢 Dengue risk notification scheduled")
            }
        }
    }

    func scheduleDailyReminder(hour: Int = 18, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "🦟 Daily Mosquito Report"
        content.body = "Have you seen any mosquitoes today? Help us track their presence by sending a report."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyReportReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling daily reminder: \(error.localizedDescription)")
            } else {
                print("🕕 Daily mosquito report reminder scheduled")
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



