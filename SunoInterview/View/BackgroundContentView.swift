//
//  BackgroundContentView.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/24/25.
//


import SwiftUI

struct BackgroundContentView : View {
    var clip:Clip
    
    var body: some View {
        VStack(alignment:.center, spacing: 0) {
            AsyncImage(url: URL(string:clip.image_large_url)!) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                        .overlay(
                            Image(systemName: "exclamationmark.triangle").foregroundStyle(.secondary)
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .ignoresSafeArea()
        .task {
            
        }
    }
}
