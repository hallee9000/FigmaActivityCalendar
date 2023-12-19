//
//  SelectColor.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/12/18.
//

import SwiftUI

struct SelectColor: View {
    @State private var hoveringIndex = 100
    @ObservedObject var settings: UserSettings

    init(settings: UserSettings) {
        self.settings = settings
    }

    var body: some View {
        VStack (spacing: 16) {
            Text("Select your favorite color")
            VStack (spacing: 4) {
                ForEach(0..<3) { row in
                    HStack (
                        spacing: 4
                    ) {
                        ForEach(0..<2) { column in
                            if row*2+column < 5 {
                                UnevenRoundedRectangle(
                                    cornerRadii: RectangleCornerRadii(
                                        topLeading: logoShapes[row*2+column][0],
                                        bottomLeading: logoShapes[row*2+column][1],
                                        bottomTrailing: logoShapes[row*2+column][2],
                                        topTrailing: logoShapes[row*2+column][3]
                                    )
                                )
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        UnevenRoundedRectangle(
                                            cornerRadii: RectangleCornerRadii (
                                                topLeading: logoShapes[row*2+column][0],
                                                bottomLeading: logoShapes[row*2+column][1],
                                                bottomTrailing: logoShapes[row*2+column][2],
                                                topTrailing: logoShapes[row*2+column][3]
                                            )
                                        )
                                            .stroke(colorPalette[row*2+column], lineWidth: 2)
                                            .frame(width: 27, height: 27)
                                            .opacity(settings.value == row*2+column ? 1 : 0)
                                    )
                                    .foregroundColor(colorPalette[row*2+column])
                                    .scaleEffect(hoveringIndex==row*2+column ? 1.1 : 1.0)
                                    .animation(.easeInOut, value: hoveringIndex==row*2+column)
                                    .onHover { hovering in
                                        if hovering {
                                            hoveringIndex = row*2+column
                                        } else {
                                            hoveringIndex = 100
                                        }
                                    }
                                    .onTapGesture {
                                        self.selectColor(colorIndex: row*2+column)
                                    }
                            } else {
                                Spacer()
                            }
                        }
                    }
                    .frame(width: 52)
                }
            }
        }
        .padding(16)
    }
    private func selectColor(colorIndex: Int) {
        settings.value = colorIndex
    }
}

struct SelectColor_Previews: PreviewProvider {
    static var previews: some View {
        SelectColor(
            settings: UserSettings(key: "ColorIndex")
        )
    }
}
