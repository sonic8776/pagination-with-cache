//
//  UserRequest.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import Foundation
import JTNetworkModule

// https://620962796df46f0017f4c4db.mockapi.io/users/userList?page=1&limit=10
struct UserRequest: RequestType {
    
    var baseURL: URL { .init(string: "https://620962796df46f0017f4c4db.mockapi.io")! }
    
    var path: String { "/users/userList" }
    
    var queryItems: [URLQueryItem]
    
    var method: HTTPMethod { .get }
    
    var body: Data? { nil }
    var headers: [String : String]? { nil}
    
    var page: Int
    let limit: Int = 10
    
    init(page: Int) {
        self.page = page
        self.queryItems = [
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)")
        ]
        if self.page > limit {
            self.page = limit
        }
    }
}
