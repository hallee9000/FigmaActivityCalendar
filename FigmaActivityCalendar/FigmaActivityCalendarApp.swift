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
        }, label: {
            HStack {
                Image(systemName: "bolt.horizontal.circle")
            }
        })
        .menuBarExtraStyle(.window)
    }
}
