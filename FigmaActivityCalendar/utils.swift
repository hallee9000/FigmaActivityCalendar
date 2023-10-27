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
        handleDailyUsageFile(prevApp: prevApp, currentApp: self.currentApp)
    }
    @objc func handleWorkspaceNotification(_ notification: Notification) {
        if let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            let prevApp = self.currentApp
            self.currentApp = activatedApp.localizedName ?? ""
            handleDailyUsageFile(prevApp: prevApp, currentApp: self.currentApp)
        }
    }
    func handleTerminate () {
        let prevApp = self.currentApp
        handleDailyUsageFile(prevApp: prevApp, currentApp: "END")
    }
}

func handleDailyUsageFile (prevApp: String, currentApp: String) {
    if !isFigmaApp(appName: prevApp) && !isFigmaApp(appName: currentApp) {
        return
    }
    // 先统计一下过往的数据
    handleUsageFile()
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

func handleUsageFile () {
    let fileManager = FileManager.default
    let usageFile = getDocumentsDirectory().appendingPathComponent("usage.csv")
    let todayDate = getDateStr(date: Date())
    
    if !fileManager.fileExists(atPath: usageFile.path) {
        // write a file with header if no file
        let header = "date,usage time,earliest,latest\n"
        do {
            try header.write(to: usageFile, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write header to file.")
            return
        }
    }
    do {
        // find file with name matches "yyyy-MM-dd"
        let folderContents = try fileManager.contentsOfDirectory(atPath: getDocumentsDirectory().path())
        let filteredFiles = folderContents.filter { folderName in
            let regex = try! NSRegularExpression(pattern: "\\d{4}-\\d{2}-\\d{2}\\.csv")
            let matches = regex.matches(in: folderName, range: NSRange(location: 0, length: folderName.utf16.count))
            return !matches.isEmpty
        }
        let existingDates = getExistingDates()
        for fileName in filteredFiles {
            if fileName != "\(todayDate).csv" && !existingDates.contains(removeExt(fileName: fileName)) {
                // read file content and calculate usage time
                calcFigmaUsageTime(filePath: fileName)
            }
        }
    } catch {
        print("Failed to access the folder: \(error)")
    }
}

func calcFigmaUsageTime (filePath: String) {
    let usageDurations = getUsageDurationsFromCSV(filePath: filePath)
    let usageFile = getDocumentsDirectory().appendingPathComponent("usage.csv")
    let earliest: String = usageDurations[0].timeString
    let latest: String = usageDurations[usageDurations.count-1].timeString
    // 统计 Figma 的使用时长
    var figmaUsageTime: TimeInterval = 0
    var previousTime: String?
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    for usageDuration in usageDurations {
        let timeString = usageDuration.timeString
        let appName = usageDuration.appName
        if !isFigmaApp(appName: appName) {
            if let time = formatter.date(from: timeString) {
                if let previousTimeString = previousTime, let previousDate = formatter.date(from: previousTimeString) {
                    let timeInterval = time.timeIntervalSince(previousDate)
                    figmaUsageTime += timeInterval
                }
            }
        }
        previousTime = timeString
    }
    let usageData = "\(removeExt(fileName: filePath)),\(figmaUsageTime),\(earliest),\(latest)\n"
    // 把统计时长写入 usage.csv
    if let fileHandle = FileHandle(forWritingAtPath: usageFile.path) {
        fileHandle.seekToEndOfFile()
        if let contentData = usageData.data(using: .utf8) {
            fileHandle.write(contentData)
            fileHandle.closeFile()
        } else {
            print("Failed to convert content to data.")
        }
    } else {
        print("Failed to open file for writing.")
    }
}

struct UsageDuration {
    let timeString: String
    var appName: String
}

func getUsageDurationsFromCSV (filePath: String) -> [UsageDuration] {
    var usageDurations:[UsageDuration] = []
    let pastUsageFilePath = getDocumentsDirectory().appendingPathComponent(filePath)
    // 读取 CSV 文件内容
    do {
        let fileContents = try String(contentsOfFile: pastUsageFilePath.path, encoding: .utf8)
        // 将文件内容按行拆分
        let rows = fileContents.components(separatedBy: .newlines)
        for row in rows {
            if row != "" {
                let columns = row.components(separatedBy: ",")
                let usageDuration = UsageDuration(timeString: columns[0], appName: columns[1])
                usageDurations.append(usageDuration)
            }
        }
    } catch {
        print("Failed to read the file: \(error)")
    }
    if usageDurations.count > 0 {
        if !isFigmaApp(appName: usageDurations[0].appName) {
            usageDurations.insert(UsageDuration(timeString: "00:00:00", appName: "Figma"), at: 0)
        }
        if isFigmaApp(appName: usageDurations[usageDurations.count-1].appName) {
            usageDurations.append(UsageDuration(timeString: "23:59:59", appName: "END"))
        }
    }
    return usageDurations
}

func getExistingDates () -> [String] {
    let usageFile = getDocumentsDirectory().appendingPathComponent("usage.csv")
    var dates: [String] = []
    do {
        let fileContents = try String(contentsOfFile: usageFile.path, encoding: .utf8)
        let rows = fileContents.components(separatedBy: .newlines)
        for row in rows {
            let columns = row.components(separatedBy: ",")
            dates.append(columns[0])
        }
        return dates
    } catch {
        print("Failed to read the file: \(error)")
    }
    return []
}

struct UsageRecord {
    let date: Date
    var usageTime: Double
}

func getUsageRecords () -> [UsageRecord] {
    let usageFile = getDocumentsDirectory().appendingPathComponent("usage.csv")
    var usageRecords: [UsageRecord] = generateInitialUsageData()
    do {
        let fileContents = try String(contentsOfFile: usageFile.path, encoding: .utf8)
        let rows = fileContents.components(separatedBy: .newlines)
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns[0] != "date" && columns[0] != "" {
                let date = columns[0]
                let usageTime = columns[1]
                if let index = usageRecords.firstIndex(where: { getDateStr(date: $0.date) == date }) {
                    var updatedRecord = usageRecords[index]
                    updatedRecord.usageTime = Double(usageTime) ?? 0
                    usageRecords[index] = updatedRecord
                }
            }
        }
        return usageRecords
    } catch {
        print("Failed to read the file: \(error)")
    }
    return []
}

func generateInitialUsageData () -> [UsageRecord] {
    let calendar = Calendar.current
    // 获取今天的日期
    let today = Date()
    // 计算 140 天之前的日期
    var dateComponents = DateComponents()
    dateComponents.day = -140
    guard let startDate = calendar.date(byAdding: dateComponents, to: today) else {
        fatalError("无法计算起始日期")
    }
    var initialData: [UsageRecord] = []
    var currentDate = startDate
    while currentDate <= today {
        let item = UsageRecord(date: currentDate, usageTime: 0)
        initialData.append(item)
        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
    }
    return initialData
}

func isFigmaApp (appName: String?) -> Bool {
    if appName == nil {
        return false
    }
    return appName == "Figma" || appName == "Figma Beta"
}

func getDateStr (date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}

func convertSecondsToHours (seconds: Double) -> String {
    let hours = seconds / 3600
    let formattedHours = String(format: "%.2f", hours)
    return formattedHours
}

func getTooltipText (row: Int, column: Int, usageRecords: [UsageRecord]) -> String {
    let date = getDateStr(date: usageRecords[row*7+column].date)
    let usageTime = convertSecondsToHours(seconds: usageRecords[row*7+column].usageTime)
    return "\(date), \(usageTime) hours"
}

func removeExt (fileName: String) -> String {
    if let fileURL = URL(string: fileName) {
        let fileNameWithoutExtension = fileURL.deletingPathExtension().lastPathComponent
        return fileNameWithoutExtension
    } else {
        return ""
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

