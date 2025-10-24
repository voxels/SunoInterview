//
//  ControlView.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/24/25.
//

import SwiftUI
import AVFoundation

struct ControlView: View {
    @Binding var audioPlayer: AudioPlayerViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Scrubber
            VStack(spacing: 6) {
                Slider(value: Binding(
                    get: { audioPlayer.currentTime },
                    set: { newValue in audioPlayer.seek(to: newValue) }
                ), in: 0...max(audioPlayer.duration, 0.1))

                HStack {
                    Text(timeString(audioPlayer.currentTime))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(timeString(max(audioPlayer.duration - audioPlayer.currentTime, 0)))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            // Transport controls
            HStack(spacing: 28) {
                Button {
                    audioPlayer.seek(by: -15)
                } label: {
                    Label("Back 15s", systemImage: "gobackward.15")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                }
                .buttonStyle(.borderless)

                Button {
                    audioPlayer.togglePlayPause()
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                .buttonStyle(.borderless)

                Button {
                    audioPlayer.seek(by: 30)
                } label: {
                    Label("Forward 30s", systemImage: "goforward.30")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Audio playback controls")
    }

    private func timeString(_ seconds: Double) -> String {
        guard seconds.isFinite && !seconds.isNaN else { return "--:--" }
        let total = Int(seconds.rounded())
        let mins = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

