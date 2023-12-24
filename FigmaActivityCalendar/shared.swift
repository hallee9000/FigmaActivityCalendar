//
//  shared.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/10/30.
//

import SwiftUI

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

func generateInitialUsageData() -> [UsageRecord] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    var lastDay = Date()

    // 判断今天是否为周六，不是周六则修改最后一天为未来最接近的周六
    let weekday = calendar.component(.weekday, from: lastDay )
    if weekday != 7 {
        var dateComponents = DateComponents()
        dateComponents.day = 7 - weekday
        lastDay = calendar.date(byAdding: dateComponents, to: lastDay) ?? lastDay
    }

    // 计算起始日期
    var dateComponents = DateComponents()
    dateComponents.day = -139
    guard let startDate = calendar.date(byAdding: dateComponents, to: lastDay) else {
        fatalError("无法计算起始日期")
    }

    var initialData: [UsageRecord] = []
    var currentDate = startDate
    while currentDate <= lastDay {
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

func getGrayColor () -> Color {
    let currentAppearance = NSApplication.shared.effectiveAppearance
    if currentAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
        return Color(red: 0.15, green: 0.15, blue: 0.15)
    } else {
        return Color(red: 0.95, green: 0.96, blue: 0.96)
    }
}

func getColorByLevel (level: Int, colorIndex: Int) -> Color {
    let opacityMaps: [Double] = [0, 0.2, 0.5, 0.8, 1]
    let opacity: Double = opacityMaps[level]
    let color: Color = colorPalette[colorIndex]
    return level==0 ? getGrayColor() : color.opacity(opacity)
}

class UserSettings: ObservableObject {
    @Published var value: Int {
        didSet {
            UserDefaults.standard.set(value, forKey: key)
        }
    }

    var key: String

    init(key: String) {
        self.key = key
        self.value = UserDefaults.standard.integer(forKey: key)
    }
}
