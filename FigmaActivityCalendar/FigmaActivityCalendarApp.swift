//
//  FigmaActivityCalendarApp.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/9/26.
//

import SwiftUI

@main
struct FigmaActivityCalendar: App {
    var body: some Scene {
        MenuBarExtra(content: {
            ContentView()
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
    }
}
