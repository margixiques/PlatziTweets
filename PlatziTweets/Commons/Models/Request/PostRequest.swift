//
//  PostRequest.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 18/08/22.
//

import Foundation

struct PostRequest: Codable {
    let text: String
    let imageUrl: String?
    let videoUrl: String?
    let location: Location?
}
