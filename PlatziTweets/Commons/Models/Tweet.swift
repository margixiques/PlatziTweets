//
//  Tweets.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 17/08/22.
//

import Foundation

struct Tweet: Codable {
    let id: String
    let author: User
    let imageUrl: String
    let text: String
    let videoUrl: String
    let location: Location
    var hasVideo: Bool = false
    var hasImage: Bool = true
    var hasLocation: Bool = false
    let createdAt: String
}
