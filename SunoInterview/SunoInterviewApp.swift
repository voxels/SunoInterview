//
//  SunoInterviewApp.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/23/25.
//

import SwiftUI

@main
struct SunoInterviewApp: App {
    @State private var networkClient:ContentNetworkClient = ContentNetworkClient()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(networkClient)
        }
    }
}
