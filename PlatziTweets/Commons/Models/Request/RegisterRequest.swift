//
//  RegisterRequest.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 17/08/22.
//

import Foundation

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let names: String
}
