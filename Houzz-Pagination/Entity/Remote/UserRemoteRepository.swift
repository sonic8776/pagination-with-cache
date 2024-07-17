//
//  UserRemoteRepository.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import Foundation

enum UserRemoteRepositoryError: Error {
    case failedToParseData
    case networkError
}

protocol UserRemoteRepositoryProtocol {
    func requestUser(fromPage page: Int, completion: @escaping (Result<[UserRemoteDTO], UserRemoteRepositoryError>) -> Void)
}

class UserRemoteRepository: UserRemoteRepositoryProtocol {
    
    let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
    
    func requestUser(fromPage page: Int, completion: @escaping (Result<[UserRemoteDTO], UserRemoteRepositoryError>) -> Void) {
        let userRequest = UserRequest(page: page)
        client.request(withRequestType: userRequest) { result in
            switch result {
            case let .success((data, _)):
                // parsing data to DTO
                do {
                    let dtos = try JSONDecoder().decode([UserRemoteDTO].self, from: data)
                    completion(.success(dtos))
                } catch {
                    completion(.failure(.failedToParseData))
                }
            case .failure(_):
                completion(.failure(.networkError))
            }
        }
    }
}
