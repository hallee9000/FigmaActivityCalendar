//
//  utils.swift
//  FigmaActivityGrid
//
//  Created by Hal on 2023/10/17.
//

import SwiftUI

class WorkspaceNotificationObserver: NSObject {
    private var currentApp = ""
    override init() {
        let prevApp = self.currentApp
        let frontmostApp = NSWorkspace.shared.frontmostApplication
        self.currentApp = frontmostApp?.localizedName ?? ""
        upsertDailyUsageFile(prevApp: prevApp, currentApp: self.currentApp)
    }
    @objc func handleWorkspaceNotification(_ notification: Notification) {
        if let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            let prevApp = self.currentApp
            self.currentApp = activatedApp.localizedName ?? ""
            upsertDailyUsageFile(prevApp: prevApp, currentApp: self.currentApp)
        }
    }
    func handleTerminate () {
        let prevApp = self.currentApp
        upsertDailyUsageFile(prevApp: prevApp, currentApp: "END")
    }
}

func upsertDailyUsageFile (prevApp: String, currentApp: String) {
    if !isFigmaApp(appName: prevApp) && !isFigmaApp(appName: currentApp) {
        return
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let todayDatetime = dateFormatter.string(from: Date())
    let parts = todayDatetime.components(separatedBy: " ")
    let todayFile = getDocumentsDirectory().appendingPathComponent("\(parts.first ?? "today").csv")
    let usage = "\(parts[1]),\(currentApp)\n"
    if FileManager.default.fileExists(atPath: todayFile.path) {
        if let fileHandle = FileHandle(forWritingAtPath: todayFile.path) {
            fileHandle.seekToEndOfFile()
            if let contentData = usage.data(using: .utf8) {
                fileHandle.write(contentData)
                fileHandle.closeFile()
            } else {
                print("Failed to convert content to data.")
            }
        } else {
            print("Failed to open file for writing.")
        }
    } else {
        // write a file if no today's file
        do {
            try usage.write(to: todayFile, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write to file.")
            return
        }
    }
}
