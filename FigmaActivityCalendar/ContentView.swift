//
//  ContentView.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/10/16.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var usageRecords:[UsageRecord] = []
    let workspaceObserver = WorkspaceNotificationObserver()
    init () {
        NSWorkspace.shared.notificationCenter.addObserver(
            workspaceObserver,
            selector: #selector(WorkspaceNotificationObserver.handleWorkspaceNotification(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }
    func initializeData () {
        self.usageRecords = getUsageRecords()
    }
    func terminate () {
        workspaceObserver.handleTerminate()
        NSApplication.shared.terminate(nil)
    }
    var body: some View {
        VStack {
            Text("Figma Activity")
            if usageRecords.count > 0 {
                HStack (spacing: 3) {
                    ForEach(0..<20) { row in
                        VStack (spacing: 3) {
                            ForEach(0..<7) { column in
                                Tile(
                                    shape: shapeValue(),
                                    color: getColorBySeconds(seconds: usageRecords[row*7+column].usageTime),
                                    text: getTooltipText(row: row, column: column, usageRecords: usageRecords)
                                )
                            }
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button("Quit") {
                    terminate()
                }.keyboardShortcut("q")
            }
        }
        .padding()
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: NSWindow.didChangeOcclusionStateNotification, object: nil, queue: nil
            ) { notification in
                if (notification.object as! NSWindow).isVisible {
                    initializeData()
                }
            }
        }
    }
    func getColorBySeconds(seconds: Double) -> Color {
        if seconds < 1800 { // less than 30 minutes
            return Color("level1")
        } else if seconds < 7200 { // less than 2 hours
            return Color("level2")
        } else if seconds < 14400 { // less than 4 hours
            return Color("level3")
        } else if seconds < 21600 { // less than 6 hours
            return Color("level4")
        } else { // more than 6 hours
            return Color("level5")
        }
    }
    func shapeValue() -> Int {
        let shape = Int.random(in: 1...4)
        return shape
    }
}

#Preview {
    ContentView()
}

