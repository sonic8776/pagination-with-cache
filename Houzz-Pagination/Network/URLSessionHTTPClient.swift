//
//  URLSessionHTTPClient.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import Foundation

class URLSessionHTTPClient: HTTPClient {
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func request(withRequestType requestType: RequestType, completion: @escaping (Result<(Data, HTTPURLResponse), HTTPClientError>) -> Void) {
        
        session.dataTask(with: requestType.urlRequest) { data, response, error in
            if let error {
                completion(.failure(.networkError))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  let data,
                  response.statusCode == 200 else {
                completion(.failure(.networkError))
                return
            }
            
            completion(.success((data, response)))
        }.resume()
    }
}
