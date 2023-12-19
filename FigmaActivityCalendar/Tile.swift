//
//  Tile.swift
//  FigmaActivityGrid
//
//  Created by Hal on 2023/10/18.
//

import SwiftUI

struct Tile: View {
    @State var isShowingPopover = false
    let shape: Int
    let color: Color
    let text: String

    var body: some View {
        UnevenRoundedRectangle(
            cornerRadii: RectangleCornerRadii(
                topLeading: tileShapes[shape][0],
                bottomLeading: tileShapes[shape][1],
                bottomTrailing: tileShapes[shape][2],
                topTrailing: tileShapes[shape][3]
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
