//
//  ContentView.swift
//  Lost in the Gardens
//
//  Created by Scott Odle on 8/28/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var navigationPath = [Int]()
    @State private var parkData: ParkDataFile?
    
    @State var isUsingCachedData: Bool = false
    
    func tryLoadData() async {
        if let dataManager = try? await DataManager(),
           let data = try? await dataManager.loadYorkStreetData() {
            print("loaded data from API")
            parkData = data
            isUsingCachedData = false
        } else {
            print("loaded data from local copy")
            parkData = .yorkStreet
            isUsingCachedData = true
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            if let parkData {
                ZStack(alignment: .bottom) {
                    MapView(withParkData: parkData)
                    if isUsingCachedData {
                        HStack {
                            Spacer()
                            Text("We're having trouble talking to our servers right now, so this information might not be up-to-date.")
                                .padding()
                            Button("Retry") {
                                Task {
                                    await tryLoadData()
                                }
                            }.padding()
                            Spacer()
                        }
                        .background(.windowBackground.opacity(0.9))
                        .clipShape(.capsule)
                    }
                }
            } else {
                Text("Loading...").onAppear {
                    Task {
                        await tryLoadData()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
