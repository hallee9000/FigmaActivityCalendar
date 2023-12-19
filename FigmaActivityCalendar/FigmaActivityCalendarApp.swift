//
//  FigmaActivityCalendarApp.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/9/26.
//

import SwiftUI

@main
struct FigmaActivityCalendar: App {
    var settings = UserSettings(key: "ColorIndex")
    @State private var name: String = "Figma Activity Calendar"
    var body: some Scene {
        MenuBarExtra(content: {
            ContentView(settings: settings)
                .background(Color("BackgroundColor"))
        }, label: {
            let image: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = 18
                $0.size.width = 18 / ratio
                return $0
            }(NSImage(named: "MenuBarIcon")!)

            Image(nsImage: image)
        })
            .menuBarExtraStyle(.window)
        Window("Settings", id: "settings") {
            Settings()
                .frame(width: 320)
        }
            .windowResizability(.contentSize)
        Window("SelectColor", id: "select-color") {
            SelectColor(settings: settings)
                .frame(width: 240, height: 240)
        }
            .windowResizability(.contentSize)
    }
}
