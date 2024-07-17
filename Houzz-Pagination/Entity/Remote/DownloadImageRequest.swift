//
//  DownloadImageRequest.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/17.
//

import Foundation

struct DownloadImageRequest: RequestType {
    
    var baseURL: URL { imageURL }
    
    var path: String { "" }
    
    var queryItems: [URLQueryItem] { [] }
    
    var method: HTTPMethod { .get }
    
    var body: Data? { nil }
    
    var headers: [String : String]? { nil }
    
    let imageURL: URL
    
    init(imageURL: URL) {
        self.imageURL = imageURL
    }
}
