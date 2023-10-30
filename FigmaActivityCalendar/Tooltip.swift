//
//  Tooltip.swift
//  FigmaActivityGrid
//
//  Created by Hal on 2023/10/16.
//
import SwiftUI

public extension View {
    /// Overlays this view with a view that provides a toolTip with the given string.
    func toolTip(_ toolTip: String?) -> some View {
        self.overlay(TooltipView(toolTip))
    }
}

private struct TooltipView: NSViewRepresentable {
    let toolTip: String?

    init(_ toolTip: String?) {
        self.toolTip = toolTip
    }

    func makeNSView(context: NSViewRepresentableContext<TooltipView>) -> NSView {
        let view = NSView()
        view.toolTip = self.toolTip
        return view
    }

    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<TooltipView>) {
    }
}
