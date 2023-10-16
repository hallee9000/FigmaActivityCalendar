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
            if activatedApp.localizedName=="Figma" {
                upsertFile()
            }
        }
    }
}

func upsertFile () {
    let str = "Super long string here"
    let filename = getDocumentsDirectory().appendingPathComponent("output.txt")
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
            VStack (spacing: 4) {
                ForEach(0..<7) { row in
                    HStack (spacing: 4) {
                        ForEach(0..<20) { column in
                            UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(topLeading: 5, bottomLeading: 5,bottomTrailing: 5,topTrailing: 2)
                            )
                                .frame(width: 10, height: 10)
                                .foregroundColor(.blue)
                                .opacity(opacityValue())
                                .toolTip("9.2 hours on Sunday, June 18, 2022")
                        }
                    }
                }
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
