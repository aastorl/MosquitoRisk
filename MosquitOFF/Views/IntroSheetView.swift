//
//  IntroSheetView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 16/06/2025.
//

import SwiftUI

struct IntroSheetView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to MosquitOFF")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text("This app monitors local weather conditions and notifies you if mosquito risk is high in your area. No manual reports, no daily spam — just smart alerts when needed.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: onDismiss) {
                Text("Got it!")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

