//
//  Logger.swift
//  Keep_Going
//
//  Created by Jaromir Jagieluk on 13.11.2025.
//

import Foundation

struct LoggingEngine {
    static let shared = LoggingEngine()
    
    private let logFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(component: "Keep_Going.log")
    
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter
        }()
    
    func appendLog(_ text: String) {
        let timestamp = dateFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] \(text)\n"
                
        guard let data = logMessage.data(using: .utf8) else { return }
        
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            do {
                let fileHandle = try FileHandle(forWritingTo: logFileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                try fileHandle.close()
            } catch {
                print("Error appending to log file: \(error)")
            }
        } else {
            do {
                try data.write(to: logFileURL, options: .atomic)
            } catch {
                print("Error creating log file: \(error)")
            }
        }
    }
    
    func getLog() -> String? {
        try? String(contentsOf: logFileURL, encoding: .utf8)
    }
    
    func logURL() -> URL {
        return logFileURL
    }
    
    func clearLog() {
        try? FileManager.default.removeItem(at: logFileURL)
    }
}
