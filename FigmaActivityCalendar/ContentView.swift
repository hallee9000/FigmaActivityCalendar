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
    @State private var shapes:[Int] = []
    @State private var name: String = "Figma Activity Calendar"
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
        VStack (spacing: 8) {
            HStack (spacing: 4) {
                Image("TitleIcon")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(name)
                Spacer()
                Popover(name: $name)
            }
            if usageRecords.count > 0 && shapes.count > 0 {
                HStack (spacing: 3) {
                    ForEach(0..<20) { row in
                        VStack (spacing: 3) {
                            ForEach(0..<7) { column in
                                Tile(
                                    shape: shapes[row*7+column],
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
                    openURL(URL(string: "https://github.com/leadream/FigmaActivityCalendar")!)
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
            self.name = name as! String
            shapes = getInitialShapes()
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
    func getInitialShapes() -> [Int] {
        var shapes = Array(repeating: 0, count: 140)
        for i in 0..<shapes.count {
            shapes[i] = Int.random(in: 1...4)
        }
        return shapes
    }
}

#Preview {
    ContentView()
}

