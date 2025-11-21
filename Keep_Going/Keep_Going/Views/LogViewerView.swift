//
//  LogViewerView.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 13.11.2025.
//

import SwiftUI

struct LogViewerView: View {
    @State private var logContent = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(logContent)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .id("bottom")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onAppear {
                        loadLogs()
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            .navigationTitle("Logs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Odśwież") {
                        loadLogs()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Wyczyść") {
                        clearLogs()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: LoggingEngine.shared.logURL()) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private func loadLogs() {
        logContent = LoggingEngine.shared.getLog() ?? "Log is empty"
    }
    
    private func clearLogs() {
        LoggingEngine.shared.clearLog()
        loadLogs()
    }
}

#Preview {
    LogViewerView()
}
