//
//  UserRemoteRepository.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import Foundation

struct UserDTO: Codable {
    
    let lastName: String
    
    enum CodingKeys: String, CodingKey {
        case lastName = "lastName"
    }
}

enum UserRemoteRepositoryError: Error {
    case failedToParseData
    case networkError
}

protocol UserRemoteRepositoryProtocol {
    func requestUser(fromPage page: Int, completion: @escaping (Result<[UserDTO], UserRemoteRepositoryError>) -> Void)
}

class UserRemoteRepository: UserRemoteRepositoryProtocol {
    
    let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
    
    func requestUser(fromPage page: Int, completion: @escaping (Result<[UserDTO], UserRemoteRepositoryError>) -> Void) {
        let userRequest = UserRequest(page: page)
        client.request(withRequestType: userRequest) { result in
            switch result {
            case let .success((data, _)):
                // parsing data to DTO
                do {
                    let dtos = try JSONDecoder().decode([UserDTO].self, from: data)
                    completion(.success(dtos))
                } catch {
                    completion(.failure(.failedToParseData))
                }
            case let .failure(_):
                completion(.failure(.networkError))
            }
        }
    }
}
