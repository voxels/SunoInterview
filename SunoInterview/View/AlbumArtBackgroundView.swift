//
//  BackgroundContentView.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/24/25.
//


import SwiftUI

struct AlbumArtBackgroundView : View {
    @Environment(ContentNetworkClient.self) private var networkClient:ContentNetworkClient

    var clip:Clip
    
    @State var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                GeometryReader { proxy in
                    let deviceWidth = proxy.size.width

                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: deviceWidth)
                            .clipped()
                            .frame(maxHeight: .infinity, alignment: .center)
                    }
                    .ignoresSafeArea(edges: .vertical)
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .vertical)
            }
        }
        .task(priority: .userInitiated) {
            do {
                if let url = clip.imageURL {
                    image = try await networkClient.fetchImage(from: url)
                }
            } catch {
                // Send to analytics
                print(error)
            }
        }
    }
}

