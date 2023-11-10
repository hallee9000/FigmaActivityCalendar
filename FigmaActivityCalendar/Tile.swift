//
//  Tile.swift
//  FigmaActivityGrid
//
//  Created by Hal on 2023/10/18.
//

import SwiftUI

struct Tile: View {
    @State private var shape1: [CGFloat] = [6, 6, 6, 6]
    @State private var shape2: [CGFloat] = [6, 6, 6, 0]
    @State private var shape3: [CGFloat] = [6, 6, 0, 0]
    @State private var shape4: [CGFloat] = [0, 0, 6, 6]
    @State private var shape5: [CGFloat] = [2, 2, 2, 2]
    @State var isShowingPopover = false
    let shape: Int
    let color: Color
    let text: String

    var body: some View {
        let selectedShape: [CGFloat]

        switch shape {
            case 1:
                selectedShape = shape1
            case 2:
                selectedShape = shape2
            case 3:
                selectedShape = shape3
            case 4:
                selectedShape = shape4
            case 5:
                selectedShape = shape5
            default:
                selectedShape = shape1
        }
        return UnevenRoundedRectangle(
            cornerRadii: RectangleCornerRadii(
                topLeading: selectedShape[0],
                bottomLeading: selectedShape[1],
                bottomTrailing: selectedShape[2],
                topTrailing: selectedShape[3]
            )
        )
            .frame(width: 12, height: 12)
            .foregroundColor(color)
            .onTapGesture {
                self.isShowingPopover = true
            }
            .popover(
                isPresented: $isShowingPopover
            ) {
                Text(text)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
            }
    }
}

struct Tile_Previews: PreviewProvider {
    static var previews: some View {
        Tile(
            shape: 1,
            color: .blue,
            text: "text"
        )
    }
}
