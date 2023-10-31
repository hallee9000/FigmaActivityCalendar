//
//  usage.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/10/30.
//

import SwiftUI

struct UsageDuration {
    let timeString: String
    var appName: String
}

class UsageStatsScheduler: NSObject {
    func start () {
        let now = Date()
        // 每半小时统计一下
        let timer = Timer(fireAt: now, interval: 30*60, target: self, selector: #selector(runTask), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    @objc func runTask() {
        updateUsageData()
    }
}

func updateUsageData () {
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
    // handle files with name matches "yyyy-MM-dd"
    do {
        let folderContents = try fileManager.contentsOfDirectory(atPath: getDocumentsDirectory().path())
        let filteredFiles = folderContents.filter { folderName in
            let regex = try! NSRegularExpression(pattern: "\\d{4}-\\d{2}-\\d{2}\\.csv")
            let matches = regex.matches(in: folderName, range: NSRange(location: 0, length: folderName.utf16.count))
            return !matches.isEmpty
        }
        let existingDates = getExistingDates()
        for fileName in filteredFiles {
            if fileName == "\(todayDate).csv" {
                updateTodayUsageData(fileName: fileName)
            } else if !existingDates.contains(removeExt(fileName: fileName)) {
                // read file content and calculate usage time
                calcFigmaUsageTime(fileName: fileName)
            }
        }
    } catch {
        print("Failed to access the folder: \(error)")
    }
}

func updateTodayUsageData (fileName: String) {
    let usageDurations = getUsageDurationsFromCSV(fileName: fileName, shouldAppendEnd: false)
    let usageFile = getDocumentsDirectory().appendingPathComponent("usage.csv")
    let usageContent = getOneDayUsageContent(fileName: fileName, usageDurations: usageDurations)
    var hasTodayData = false
    do {
        let fileContents = try String(contentsOfFile: usageFile.path, encoding: .utf8)
        // 将文件内容按行拆分
        var lines = fileContents.components(separatedBy: .newlines)
        for (index, line) in lines.enumerated() {
            if line.hasPrefix(removeExt(fileName: fileName)) {
                let filteredUsageContent = usageContent.replacingOccurrences(of: "\n", with: "")
                lines[index] = filteredUsageContent
                hasTodayData = true
                break
            }
        }
        if !hasTodayData {
            // 追加
            calcFigmaUsageTime(fileName: fileName)
        } else {
            // 将修改后的内容拼接回字符串
            let updatedFileContents = lines.joined(separator: "\n")
            // 将修改后的内容写回到文件
            try updatedFileContents.write(to: usageFile, atomically: true, encoding: .utf8)
        }
    } catch {
        print("Failed to read the file: \(error)")
    }
}

func calcFigmaUsageTime (fileName: String) {
    let usageDurations = getUsageDurationsFromCSV(fileName: fileName, shouldAppendEnd: true)
    let usageFile = getDocumentsDirectory().appendingPathComponent("usage.csv")
    // 把统计时长写入 usage.csv
    if let fileHandle = FileHandle(forWritingAtPath: usageFile.path) {
        fileHandle.seekToEndOfFile()
        let usageContent = getOneDayUsageContent(fileName: fileName, usageDurations: usageDurations)
        if let contentData = usageContent.data(using: .utf8) {
            fileHandle.write(contentData)
            fileHandle.closeFile()
        } else {
            print("Failed to convert content to data.")
        }
    } else {
        print("Failed to open file for writing.")
    }
}

func getUsageDurationsFromCSV (fileName: String, shouldAppendEnd: Bool) -> [UsageDuration] {
    var usageDurations:[UsageDuration] = []
    let pastUsageFilePath = getDocumentsDirectory().appendingPathComponent(fileName)
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
        if isFigmaApp(appName: usageDurations.last?.appName) && shouldAppendEnd {
            usageDurations.append(UsageDuration(timeString: "23:59:59", appName: "END"))
        }
    }
    return usageDurations
}

func getOneDayUsageContent (fileName: String, usageDurations: [UsageDuration]) -> String {
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
    return "\(removeExt(fileName: fileName)),\(figmaUsageTime),\(earliest),\(latest)\n"
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
