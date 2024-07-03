//
//  HTTPClient.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import Foundation

protocol HTTPClient {
    func request(withRequestType requestType: RequestType, completion: @escaping (Result<(Data, HTTPURLResponse), HTTPClientError>) -> Void)
}

enum HTTPClientError: Error {
    case networkError
}
