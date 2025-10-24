//
//  InfoView.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/24/25.
//


import SwiftUI

struct ClipView : View {
    var clip:Clip
    @Binding var audioPlayer: AudioPlayerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let deviceWidth = geometry.size.width
            ZStack(alignment: .center) {
                VStack(spacing:0) {
                    Spacer()
                    HStack(spacing: 0) {
                        VStack(alignment:.leading, spacing:4) {
                            Text(clip.title)
                                .font(.largeTitle)
                                .lineLimit(2)
                            Text(clip.handle)
                                .font(.title2)
                                .lineLimit(2)
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .foregroundStyle(.primary, .secondary)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 16))
                    .contentShape(.rect(cornerRadius: 16))
                    Divider()
                        .padding(.vertical,2)
                    ControlView(audioPlayer: $audioPlayer)
                        .foregroundStyle(.primary)
                        .padding(.vertical)
                        .background(.thickMaterial)
                        .clipShape(.rect(cornerRadius: 16))
                        .contentShape(.rect(cornerRadius: 16))
                }
                .padding()
            }
            .frame(width: deviceWidth)
        }
    }
}

