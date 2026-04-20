//
//  InfoPrevSheet.swift
//

import SwiftUI

struct InfoPrevSheet: View {
    var body: some View {
        TabView {
            // ── Tab 1: ¿Cómo se calcula? ──────────────────────────
            RiskInfoSheetView()
                .tabItem {
                    Label("Cómo se calcula", systemImage: "chart.bar.fill")
                }

            // ── Tab 2: Cómo protegerme ─────────────────────────────
            PreventionGuideView()
                .tabItem {
                    Label("Protegerme", systemImage: "shield.checkerboard")
                }
        }
        .tint(.white)
        .presentationCornerRadius(24)
    }
}

#Preview {
    InfoPrevSheet()
}
