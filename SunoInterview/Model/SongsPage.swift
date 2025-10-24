//
//  SongsPage.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/24/25.
//


import SwiftUI
import Foundation

// Top-level page wrapper for the API response
public struct SongsPage: Codable, Sendable, Equatable, Hashable {
    public let end: Int
    public let page: Int
    public let per_page: Int
    public let songs: [SongEntry]
    public let start: Int
    public let total_pages: Int
    public let total_songs: Int

    public enum CodingKeys: String, CodingKey {
        case end, page
        case per_page
        case songs
        case start
        case total_pages
        case total_songs
    }
}

// Each array element under "songs" holds a "clip" object (plus other fields we don't need)
public struct SongEntry: Codable, Sendable, Equatable, Hashable {
    public let clip: Clip
}

// The "clip" object contains the fields we want to surface
public struct Clip: Codable, Sendable, Equatable, Hashable {
    
    public var id:String
    public let title:String
    public let handle:String
    public let image_large_url:String
    public let is_liked:Bool
    public let upvote_count:Int

    public init(id: String,
                title: String,
                handle: String,
                image_large_url: String,
                is_liked: Bool,
                upvote_count: Int) {
        self.id = id
        self.title = title
        self.handle = handle
        self.image_large_url = image_large_url
        self.is_liked = is_liked
        self.upvote_count = upvote_count
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.handle, forKey: .handle)
        try container.encode(self.image_large_url, forKey: .image_large_url)
        try container.encode(self.is_liked, forKey: .is_liked)
        try container.encode(self.upvote_count, forKey: .upvote_count)
    }

    public enum CodingKeys: CodingKey {
        case id
        case title
        case handle
        case image_large_url
        case is_liked
        case upvote_count
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.handle = try container.decode(String.self, forKey: .handle)
        self.image_large_url = try container.decode(String.self, forKey: .image_large_url)
        self.is_liked = try container.decode(Bool.self, forKey: .is_liked)
        self.upvote_count = try container.decode(Int.self, forKey: .upvote_count)
    }

    public static func == (lhs: Clip, rhs: Clip) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
