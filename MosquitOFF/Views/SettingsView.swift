//
//  SettingsView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 10/05/2025.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var notificationsAllowed = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notificaciones")) {
                    Toggle("Recibir notificaciones", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue {
                                // Si el usuario activa, pedimos permiso y chequeamos estado
                                NotificationManager.shared.requestPermission()
                                checkNotificationPermission()
                            } else {
                                // Si desactiva, eliminamos notificaciones y actualizamos estado
                                NotificationManager.shared.removeAllNotifications()
                                notificationsAllowed = false
                            }
                        }

                    HStack {
                        Text("Permiso del sistema")
                        Spacer()
                        Image(systemName: notificationsAllowed ? "checkmark.circle.fill" : "xmark.octagon.fill")
                            .foregroundColor(notificationsAllowed ? .green : .red)
                    }

                    if !notificationsAllowed {
                        Button("Abrir configuración del sistema") {
                            if let url = URL(string: UIApplication.openSettingsURLString),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundColor(.blue)
                    }

                    Text("Recibirás alertas automáticamente cuando el riesgo de mosquitos sea alto en tu zona.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .navigationTitle("Configuración")
            .onAppear {
                checkNotificationPermission()
                // Si no hay permiso, forzamos toggle en OFF
                if !notificationsAllowed {
                    notificationsEnabled = false
                }
            }
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsAllowed = settings.authorizationStatus == .authorized
            }
        }
    }
}


