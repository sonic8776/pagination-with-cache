//
//  RequestType.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol RequestType {
    var baseURL: URL { get } // domain URL https://crypto.com
    var path: String { get } // /userLogin
    var queryItems: [URLQueryItem] { get } // https://crypto.com/userLogin?account=judy&passwork=1234
    var fullURL: URL { get } // base + path + queryItems
    var method: HTTPMethod { get } // GET, POST
    var body: Data? { get } // POST parameters
    var headers: [String: String]? { get } // cooike, session, token
    var urlRequest: URLRequest { get } // final
}

extension RequestType {
    var fullURL: URL {
        // Builder pattern 可以再被修改 / factory 創建好不能再被修改
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path += path
        components?.queryItems = queryItems
        guard let url = components?.url else {
            fatalError("Invalid URL components: \(String(describing: components))")
        }
        return url
    }
    
    var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body
        if let headers = headers {
            for (headerField, headerValue) in headers {
                urlRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        return urlRequest
    }
}

