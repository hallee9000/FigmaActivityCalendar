//
//  utils.swift
//  FigmaActivityGrid
//
//  Created by Hal on 2023/10/17.
//

import SwiftUI

class WorkspaceNotificationObserver: NSObject {
    @objc func handleWorkspaceNotification(_ notification: Notification) {
        if let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            if activatedApp.localizedName=="Figma" {
                getDayUsage()
            }
        }
    }
}

func getDayUsage () {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let currentDate = dateFormatter.string(from: Date())
    let filePath = getDocumentsDirectory().appendingPathComponent("\(currentDate).csv")
    
    if !FileManager.default.fileExists(atPath: filePath.path) {
        // 如果文件不存在，则创建文件并写入表头
        let header = "日期,开始时间,结束时间\n"

        do {
            try header.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write header to file.")
            return
        }
    }
    print(filePath)
}

func upsertFile () {
    let str = "Super long string here"
    let filename = getDocumentsDirectory().appendingPathComponent("today.txt")
    print(filename)
    do {
        try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
