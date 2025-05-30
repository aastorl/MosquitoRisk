//
//  ButtonStyles.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 22/05/2025.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue.opacity(configuration.isPressed ? 0.7 : 0.9))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 3)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.red.opacity(configuration.isPressed ? 0.7 : 0.9))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 3)
    }
}

