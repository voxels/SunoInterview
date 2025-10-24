//
//  ContentView.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/23/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(ContentNetworkClient.self) private var networkClient:ContentNetworkClient 
    @State private var model:ContentViewModel = .init()
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack(root: {
                ZStack(alignment: .center) {
                    Color.clear
                        .ignoresSafeArea()
                    PagingView(clips: $model.clips)
                }
                .task(priority: .utility) {
                    do {
                        model.clips = try await networkClient.fetchModel().get()
                    } catch {
                        // report to analytics
                        // gracefully handle the error
                        print(error)
                        fatalError()
                    }
                }
            })
        }
    }
}



