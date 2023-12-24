//
//  Settings.swift
//  FigmaActivityCalendar
//
//  Created by Hal on 2023/10/25.
//

import SwiftUI
import Foundation
import LaunchAtLogin

struct Release: Codable {
    let html_url: String
    let tag_name: String
}

struct Settings: View {
    @Environment(\.openURL) var openURL
    let version = "V1.2.1"
    @State private var latestLink: String = ""
    var body: some View {
        VStack () {
            Image("AppLogo")
                .resizable()
                .frame(width: 64, height: 64)
            Text("Figma Activity Calendar")
                .bold()
            Text(version)
            Button("Buy me a coffee", systemImage: "cup.and.saucer.fill", action: {
                openURL(URL(string: "https://www.buymeacoffee.com/hal__lee")!)
            })
            Spacer()
            LaunchAtLogin.Toggle()
            Button("Check for updates") {
                Task {
                    await fetchData()
                }
            }
            if latestLink != "" {
                if latestLink == "yes" {
                    Text("You are already using the latest version.")
                } else {
                    Text("Your version is a bit outdated.")
                    HStack {
                        Text("Click")
                        Link("here", destination: URL(string: latestLink)!)
                        Text("to download the latest version.")
                    }
                }
            }
            Button("Show usage in Finder") {
                let usageFile = getDocumentsDirectory().appendingPathComponent("usage.csv")
                let folderURL = URL(fileURLWithPath: usageFile.path)
                NSWorkspace.shared.activateFileViewerSelecting([folderURL])
            }
        }
        .padding(16)
        .frame(maxHeight: .infinity)
    }
    private func fetchData() async {
        let repoName = "leadream/FigmaActivityCalendar"
        let apiUrl = "https://api.github.com/repos/\(repoName)/releases/latest"

        let url = URL(string: apiUrl)!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print(data)
            do {
                let release = try JSONDecoder().decode(Release.self, from: data)
                if release.tag_name != version {
                    latestLink = release.html_url
                } else {
                    latestLink = "yes"
                }
                
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        } catch {
            print(error)
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
