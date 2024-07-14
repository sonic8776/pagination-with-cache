//
//  UserLocalRepository.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/11.
//

import Foundation

struct UserLocalDTO: Codable {
    let createAt: String
    let firstName: String
    let lastName: String
    let avatar: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case createAt
        case firstName
        case lastName
        case avatar
        case id
    }
}

enum UserLocalRepositoryResult {
    case empty
    case found(UserLocalDTO)
}

protocol UserLocalRepositoryProtocol {
    func loadUser(withID id: String, completion: @escaping (UserLocalRepositoryResult) -> Void)
    func saveUser(fromRemote user: UserRemoteDTO)
}

class UserLocalRepository: UserLocalRepositoryProtocol {
    
    func loadUser(withID id: String, completion: @escaping (UserLocalRepositoryResult) -> Void) {
        
    }
    
    func saveUser(fromRemote user: UserRemoteDTO) {
        
    }
}
