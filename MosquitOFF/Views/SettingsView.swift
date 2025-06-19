//
//  SettingsView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 10/05/2025.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @State private var notificationsAllowed = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    HStack {
                        Text("System Permission")
                        Spacer()
                        Image(systemName: notificationsAllowed ? "checkmark.circle.fill" : "xmark.octagon.fill")
                            .foregroundColor(notificationsAllowed ? .green : .red)
                    }

                    if !notificationsAllowed {
                        Button("Open System Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundColor(.blue)
                    }

                    Text("You'll automatically receive alerts when mosquito risk is high in your area.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                checkNotificationPermission()
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

