//
//  Header.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/11/10.
//

import SwiftUI

struct Header: View {
    @Environment(\.openWindow) var openWindow
    @State private var name: String = "Figma Activity Calendar"
    @State private var isEditing = false
    var body: some View {
        HStack (spacing: 4) {
            Image("TitleIcon")
                .resizable()
                .frame(width: 20, height: 20)
            if isEditing {
                TextField("Name", text: $name, onCommit: {
                    saveName(name: name)
                    isEditing.toggle()
                })
            } else {
                Text(name)
                    .gesture(TapGesture(count: 2).onEnded {
                        isEditing.toggle()
                    })
            }
            Spacer()
            Button(action: {
                openWindow(id: "settings")
            }) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            let name = UserDefaults.standard.value(forKey: "Name")
            if (name != nil) {
                self.name = name as! String
            }
        }
    }
    private func saveName(name: String) {
        UserDefaults.standard.set(name, forKey: "Name")
        UserDefaults.standard.synchronize()
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        Header()
    }
}
