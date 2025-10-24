//
//  ContentViewModel.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/23/25.
//

import SwiftUI
import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

public let defaultServerURL:URL = URL(string:"https://apitest.suno.com/api/songs")!

public var defaultSession:URLSession {
    get {
        let configuration:URLSessionConfiguration = .default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 10.0
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession(configuration: configuration)
        return session
    }
}

public protocol NetworkClient {
    func fetchModel(_ session: URLSession?,
                           from url: URL?) async throws -> Result<[Clip], Error>
    
#if canImport(UIKit)
    func fetchImage(from url: URL, using session: URLSession) async throws -> UIImage
#endif

#if canImport(AppKit)
    func fetchImage(from url: URL, using session: URLSession?) async throws -> NSImage
#endif
}


@Observable
public final class ContentNetworkClient {
    
#if canImport(UIKit)
    private static let imageCache = NSCache<NSURL, UIImage>()
#endif
#if canImport(AppKit)
    private static let imageCache_macOS = NSCache<NSURL, NSImage>()
#endif
    
    public func fetchModel(_ session: URLSession? = nil,
                           from url: URL? = nil) async throws -> Result<[Clip], Error> {
        let resolvedURL = url ?? defaultServerURL
        let session = session ?? defaultSession
        let (data, _) = try await session.data(from: resolvedURL)
        let page = try JSONDecoder().decode(SongsPage.self, from: data)
        let mapped: [Clip] = page.songs.map { entry in
            entry.clip
        }
        return .success(mapped)
    }
    
#if canImport(UIKit)
    public func fetchImage(from url: URL, using session: URLSession? = nil) async throws -> UIImage {
        let nsURL = url as NSURL
        if let cached = ContentNetworkClient.imageCache.object(forKey: nsURL) {
            return cached
        }
        let session = session ?? defaultSession
        let (data, _) = try await session.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        let cost = Int(image.size.width * image.size.height * image.scale * image.scale * 4)
        ContentNetworkClient.imageCache.setObject(image, forKey: nsURL, cost: cost)
        return image
    }
#endif

#if canImport(AppKit)
    public func fetchImage(from url: URL, using session: URLSession? = nil) async throws -> NSImage {
        let nsURL = url as NSURL
        if let cached = ContentViewModel.imageCache_macOS.object(forKey: nsURL) {
            return cached
        }
        let session = session ?? ContentViewModel.session
        let (data, _) = try await session.data(from: url)
        guard let image = NSImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        // Estimate cost using pixel count (width * height * 4 bytes)
        let repSize = image.representations.first.map { CGSize(width: $0.pixelsWide, height: $0.pixelsHigh) } ?? image.size
        let cost = Int(repSize.width * repSize.height * 4)
        ContentViewModel.imageCache_macOS.setObject(image, forKey: nsURL, cost: cost)
        return image
    }
#endif
}

