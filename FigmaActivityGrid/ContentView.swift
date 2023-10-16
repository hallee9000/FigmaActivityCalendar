//
//  ContentView.swift
//  FigmaActivityGrid
//
//  Created by Hal on 2023/10/16.
//

import SwiftUI
import AppKit

class WorkspaceNotificationObserver: NSObject {
    @objc func handleWorkspaceNotification(_ notification: Notification) {
        if let activatedApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            print(activatedApp.localizedName ?? "dd")
            // 在这里添加处理窗口激活事件的逻辑
        }
    }
}

struct ContentView: View {
    let workspaceObserver = WorkspaceNotificationObserver()
    init() {
        print("Init")
        NSWorkspace.shared.notificationCenter.addObserver(
            workspaceObserver,
            selector: #selector(WorkspaceNotificationObserver.handleWorkspaceNotification(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }
    var body: some View {
        VStack {
            Text("Figma Activity")
            VStack {
                ForEach(0..<5) { row in
                    HStack {
                        ForEach(0..<7) { column in
                            Rectangle()
                                .frame(width: 8, height: 8)
                                .cornerRadius(2)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
