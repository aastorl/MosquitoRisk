//
//  ReportListView.swift
//  MosquitOFF
//
//  Created by Astor Ludueña  on 06/05/2025.
//

// Deprecated

import SwiftUI

struct ReportListView: View {
    @State private var reports: [Report] = []
    private let reportManager = ReportManager()

    var body: some View {
        List {
            ForEach(reports) { report in
                VStack(alignment: .leading) {
                    Text(report.type)
                        .font(.headline)
                    Text(report.description)
                        .font(.subheadline)
                    Text("Fecha: \(formatDate(report.timestamp))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Reportes Enviados")
        .onAppear(perform: loadReports)
    }

    func loadReports() {
        reports = reportManager.loadReports()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            let report = reports[index]
            reportManager.deleteReport(id: report.id)
        }
        loadReports()
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
