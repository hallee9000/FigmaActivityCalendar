//
//  ContentView.swift
//  FigmaActivityGrid
//
//  Created by Hal on 2023/10/16.
//

import SwiftUI
import AppKit

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
            VStack (spacing: 2) {
                ForEach(0..<7) { row in
                    HStack (spacing: 2) {
                        ForEach(0..<20) { column in
                            RoundedRectangle(
                                cornerRadius: 2
                            )
                                .frame(width: 12, height: 12)
                                .foregroundColor(.blue)
                                .opacity(opacityValue())
                                .toolTip("9.2 hours on Sunday, June 18, 2022")
                        }
                    }
                }
            }
            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }.keyboardShortcut("q")
            }
        }
        .padding()
    }
    func opacityValue() -> Double {
        let opacity = Double.random(in: 0..<1)
        return opacity
    }
}

#Preview {
    ContentView()
}
