//
//  InfoPage.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 9/25/26.
//

import SwiftUI

struct InfoPage: View {
    var body: some View {
        VStack {
            Text("Lost in the Gardens")
                .font(.largeTitle)
            if let icon = UIImage(named: "AppIcon") {
                Image(uiImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }
            VStack {
                if let infoDict = Bundle.main.infoDictionary {
                    if let version = infoDict["CFBundleShortVersionString"] as? String {
                        Text("Version: \(version)")
                    }
                    if let build = infoDict["CFBundleVersion"] as? String {
                        Text("Build: \(build)")
                    }
                }
            }.padding()
            VStack {
                Text("Copyright ©️ 2026 by [Choice Paralysis Ltd.](https://choiceparalysis.com)")
                Text("Logo design by [Andrew Roman](https://aero-man.github.io/)")
            }.padding()
            Text("This app is not affiliated with the Denver Botanic Gardens.").multilineTextAlignment(.center)
        }.navigationTitle(Text("About"))
    }
}

#Preview {
    InfoPage()
}
