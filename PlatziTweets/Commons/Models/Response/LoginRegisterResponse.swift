//
//  LoginResponse.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 17/08/22.
//

import Foundation


struct LoginRegisterResponse: Codable {
    let user: User
    let token: String
}
