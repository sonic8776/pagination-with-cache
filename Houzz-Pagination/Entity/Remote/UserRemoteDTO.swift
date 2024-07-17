//
//  UserRemoteDTO.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/17.
//

import Foundation

struct UserRemoteDTO: Codable {
    
    let id: String
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case lastName = "lastName"
    }
}
