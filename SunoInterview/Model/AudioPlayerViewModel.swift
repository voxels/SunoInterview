//
//  AudioPlayerViewModel.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/24/25.
//


import SwiftUI
import AVFoundation

@Observable
public final class AudioPlayerViewModel {
    public var isPlaying: Bool = false
    public var currentTime: Double = 0
    public var duration: Double = 0

    private var player: AVQueuePlayer?
    private var timeObserver: Any?
    private var clips:[Clip] = []
    private var interruptionObserver: NSObjectProtocol?
    private var routeChangeObserver: NSObjectProtocol?
    private var didSetupObservers:Bool = false

    public func prepareAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // Configure session for playback (even with Silent Mode)
            try session.setCategory(.playback, mode: .default, policy: .default, options: [])
            try session.setActive(true, options: [])
        } catch {
            print("Audio session setup failed: \(error)")
        }
        
        setupObservers()
    }
    
    deinit {
        if let obs = timeObserver {
            player?.removeTimeObserver(obs)
        }
        if let interruptionObserver {
            NotificationCenter.default.removeObserver(interruptionObserver)
        }
        if let routeChangeObserver {
            NotificationCenter.default.removeObserver(routeChangeObserver)
        }
    }
    
    // MARK: - Public API
    /// Replace the current list of clips and rebuild the playback queue.
    /// Calling this will reset the player to the beginning of the new queue.
    public func setClips(_ newClips: [Clip]) {
        // Store
        self.clips = newClips

        // Build items from clips
        let items: [AVPlayerItem] = newClips.compactMap { clip in
            // Assuming Clip exposes a URL for playback; adjust if needed.
            if let url = clip.audioURL {
                return AVPlayerItem(url: url)
            } else {
                return nil
            }
        }

        if player == nil {
            // Initialize queue player first time
            let queuePlayer = AVQueuePlayer(items: items)
            self.player = queuePlayer
            setupPlayerObservers(queuePlayer)
        } else {
            // Replace all items on existing queue
            player?.removeAllItems()
            items.forEach { player?.insert($0, after: nil) }
        }

        // Reset timing state
        self.currentTime = 0
        self.duration = 0
        if let first = items.first {
            Task { [weak self] in
                guard let self else { return }
                do {
                    let dur = try await first.asset.load(.duration)
                    let seconds = dur.seconds
                    await MainActor.run {
                        self.duration = seconds.isFinite ? seconds : 0
                    }
                } catch {
                    await MainActor.run {
                        self.duration = 0
                    }
                }
            }
        }
        self.isPlaying = false
    }
    
    /// Select a clip by its identifier and load that clip into the player as the current item.
    /// - Parameter id: The unique identifier for the `Clip` to play.
    /// If the clip is found, the queue is reordered so the selected clip is current,
    /// timing state is updated, and playback continues if it was already playing.
    public func selectClip(withID id: String) {
        // Ensure we have a player and a populated list of clips
        if player == nil { player = AVQueuePlayer() }
        guard let player else { return }

        // Find the index of the requested clip
        guard let index = clips.firstIndex(where: { $0.id == id }) else {
            return
        }

        // Build items from all clips (maintain the same order)
        let items: [AVPlayerItem] = clips.compactMap { clip in
            guard let url = clip.audioURL else { return nil }
            return AVPlayerItem(url: url)
        }

        // Guard against empty items or out-of-range index due to missing URLs
        guard !items.isEmpty, index < items.count else { return }

        // Rebuild the queue so that the selected clip is the current item.
        // Strategy: Remove all, then insert starting from the selected index to end,
        // followed by the items from the beginning up to the selected index.
        player.removeAllItems()
        let reordered = Array(items[index...]) + Array(items[..<index])
        reordered.forEach { player.insert($0, after: nil) }

        // Reset timing to start of the selected item and update duration
        currentTime = 0
        duration = 0
        if let currentItem = player.currentItem {
            Task { [weak self] in
                guard let self else { return }
                do {
                    let dur = try await currentItem.asset.load(.duration)
                    let seconds = dur.seconds
                    await MainActor.run {
                        self.duration = seconds.isFinite ? seconds : 0
                    }
                } catch {
                    await MainActor.run {
                        self.duration = 0
                    }
                }
            }
        }

        // If we were playing already, continue playback; otherwise remain paused
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }
    }
    
    private func setupPlayerObservers(_ player:AVQueuePlayer) {
        // Observe periodic time to update slider and labels
        let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            self.currentTime = time.seconds
            if let item = player.currentItem {
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        let duration = try await item.asset.load(.duration)
                        let seconds = duration.seconds
                        await MainActor.run {
                            if seconds.isFinite { self.duration = seconds }
                        }
                    } catch {
                        // Ignore duration update errors
                    }
                }
            }
        }

        // Observe end of playback to reset state
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            player.seek(to: .zero)
            self.isPlaying = false
        }
    }

    private func setupObservers() {
        didSetupObservers = false
        // Observe interruptions (e.g., phone calls, Siri)
        interruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] notification in
            guard let self, let player else { return }
            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

            switch type {
            case .began:
                if self.isPlaying {
                    player.pause()
                    self.isPlaying = false
                }
            case .ended:
                let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue ?? 0)
                if options.contains(.shouldResume) {
                    player.play()
                    self.isPlaying = true
                }
            @unknown default:
                break
            }
            
        }

        // Observe route changes (e.g., headphones unplugged)
        routeChangeObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main) { [weak self] notification in
            guard let self, let player else { return }
            guard let userInfo = notification.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

            if reason == .oldDeviceUnavailable {
                if self.isPlaying {
                    player.pause()
                    self.isPlaying = false
                }
            }
        }
        didSetupObservers = true
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    func seek(by seconds: Double) {
        let newTime = max(0, min((currentTime + seconds), duration))
        seek(to: newTime)
    }

    func seek(to seconds: Double) {
        guard let player else { return }
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player.seek(to: time)
        currentTime = seconds
    }
}

