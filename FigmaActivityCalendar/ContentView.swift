//
//  ContentView.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/10/16.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @State private var usageRecords:[UsageRecord] = []
    @State private var name: String = "Figma Activity Calendar"
    let workspaceObserver = WorkspaceNotificationObserver()
    init () {
        NSWorkspace.shared.notificationCenter.addObserver(
            workspaceObserver,
            selector: #selector(WorkspaceNotificationObserver.handleWorkspaceNotification(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
        let usageStatsScheduler = UsageStatsScheduler()
        usageStatsScheduler.start()
    }
    func terminate () {
        workspaceObserver.handleTerminate()
        NSApplication.shared.terminate(nil)
    }
    var body: some View {
        VStack (spacing: 8) {
            HStack (spacing: 4) {
                Image("TitleIcon")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(name)
                Spacer()
                Popover(name: $name)
            }
            if usageRecords.count > 0 {
                HStack (spacing: 3) {
                    ForEach(0..<20) { row in
                        VStack (spacing: 3) {
                            ForEach(0..<7) { column in
                                Tile(
                                    shape: getShapeBySeconds(seconds: usageRecords[row*7+column].usageTime),
//                                    color: randomColor(),
                                    color: getColorBySeconds(seconds: usageRecords[row*7+column].usageTime),
                                    text: getTooltipText(row: row, column: column, usageRecords: usageRecords)
                                )
                            }
                        }
                    }
                }
            } else {
                VStack {
                    Image(systemName: "tray")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray)
                    Text("No data for now. Please open Figma desktop and keep this app open.")
                        .foregroundColor(.gray)
                }
                .padding()
            }
            HStack {
                Button(action: {
                    openURL(URL(string: "https://github.com/leadream/FigmaActivityCalendar#figma-activity-calendar")!)
                }) {
                    Image(systemName: "questionmark.circle")
                }
                    .buttonStyle(PlainButtonStyle())
                Spacer()
                Button("Quit") {
                    terminate()
                }.keyboardShortcut("q")
            }
        }
        .padding()
        .onAppear {
            let name = UserDefaults.standard.value(forKey: "Name")
            if (name != nil) {
                self.name = name as! String
            }
            NotificationCenter.default.addObserver(
                forName: NSWindow.didChangeOcclusionStateNotification, object: nil, queue: nil
            ) { notification in
                if (notification.object as! NSWindow).isVisible {
                    self.usageRecords = getUsageRecords()
                    // 每次打开也更新一下
                    updateUsageData()
                }
            }
        }
    }
    func getShapeBySeconds(seconds: Double) -> Int {
        if seconds < 60 { // less than 1 minutes
            return 1
        } else if seconds < 1800 { // less than 30 minutes
            return 2
        } else if seconds < 10800 { // less than 3 hours
            return 3
        } else if seconds < 21600 { // less than 6 hours
            return 4
        } else { // more than 6 hours
            return 5
        }
    }
    func getColorBySeconds(seconds: Double) -> Color {
        if seconds < 60 { // less than 1 minutes
            return Color("level1")
        } else if seconds < 1800 { // less than 30 minutes
            return Color("level2")
        } else if seconds < 10800 { // less than 3 hours
            return Color("level3")
        } else if seconds < 21600 { // less than 6 hours
            return Color("level4")
        } else { // more than 6 hours
            return Color("level5")
        }
    }
    func getWeekdayAbbreviation(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"  // 设置日期格式为仅星期几的缩写
        return dateFormatter.string(from: date)
    }

    func convertSecondsToHours (seconds: Double) -> String {
        let hours = seconds / 3600
        let formattedHours = String(format: "%.2f", hours)
        return formattedHours
    }

    func getTooltipText (row: Int, column: Int, usageRecords: [UsageRecord]) -> String {
        let weekday = getWeekdayAbbreviation(usageRecords[row*7+column].date)
        let date = getDateStr(date: usageRecords[row*7+column].date)
        let usageTime = convertSecondsToHours(seconds: usageRecords[row*7+column].usageTime)
        return "\(weekday), \(date), \(usageTime) hours"
    }
}

#Preview {
    ContentView()
}
