//
//  Popover.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/10/25.
//

import SwiftUI

struct Popover: View {
    @State private var isPopoverVisible = false
    @Binding var name: String

    var body: some View {
        Button(action: {
            self.isPopoverVisible = true
        }) {
            Image(systemName: "gearshape")
        }
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $isPopoverVisible) {
            VStack (alignment: .leading) {
                HStack () {
                    Text ("Settings")
                        .bold()
                    Spacer()
                }
                LabeledContent {
                    TextField("Name", text: $name, onCommit: {
                        saveName(name: name)
                    })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } label: {
                    Text("Name")
                }
                LabeledContent {
                    Button("Show usage in Finder") {
                        let usageFile = getDocumentsDirectory().appendingPathComponent("usage.csv")
                        let folderURL = URL(fileURLWithPath: usageFile.path)
                        NSWorkspace.shared.activateFileViewerSelecting([folderURL])
                    }
                } label: {
                    Text("Action")
                }
            }
            .frame(width: 200)
            .padding(16)
        }
    }
    private func saveName(name: String) {
        UserDefaults.standard.set(name, forKey: "Name")
        UserDefaults.standard.synchronize()
    }
}

struct Popover_Previews: PreviewProvider {
    static var previews: some View {
        Popover(name: .constant("Figma Activity Calendar"))
    }
}
