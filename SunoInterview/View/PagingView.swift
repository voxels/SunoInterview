//
//  PagingView.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/24/25.
//


import SwiftUI

struct PagingView : View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding public var clips:[Clip]
    @State private var audioPlayer:AudioPlayerViewModel = .init()

    var body: some View {
        GeometryReader{ geometry in
            ScrollViewReader { reader in
                ScrollView(.horizontal) {
                    LazyHStack(alignment: .center, spacing:0) {
                        ForEach(clips, id: \.self) { clip in
                            ZStack(alignment: .center) {
                                    AlbumArtBackgroundView(clip: clip)
                                    .frame(width:geometry.size.width, alignment: .init(horizontal: .center, vertical: .center))
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        (colorScheme == .dark ? Color.black.opacity(0.35) : Color.white.opacity(0.35))
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .ignoresSafeArea()
                                ClipView(clip: clip, audioPlayer:$audioPlayer)
                                    .onAppear {
                                        // Ensure the selected clip becomes current when its view appears
                                        audioPlayer.selectClip(withID: clip.id)
                                        audioPlayer.seek(to: 0)
                                    }
                            }
                        }
                    }
                }
                .task {
                    audioPlayer.prepareAudioSession()
                    audioPlayer.setClips(clips)
                }
                .scrollTargetBehavior(.paging)
            }
        }
    }
}

