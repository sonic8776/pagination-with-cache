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
    
    init(createAt: String, firstName: String, lastName: String, avatar: String, id: String) {
        self.createAt = createAt
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.id = id
    }
    
    static func toDTO(fromJson json: Any) -> UserLocalDTO? {
        guard let json = json as? [String: Any] else { return nil }
        let id = json["id"] as? String ?? ""
        let lastName = json["lastName"] as? String ?? ""
        return .init(createAt: "", firstName: "", lastName: lastName, avatar: "", id: id)
    }
}

enum UserLocalRepositoryResult {
    case empty
    case found(UserLocalDTO)
    case decodeError
    case encodeError
    case saveError
}

protocol UserLocalRepositoryProtocol {
    func loadUser(withID id: String, completion: @escaping (UserLocalRepositoryResult) -> Void)
    func saveUser(fromRemote user: UserRemoteDTO, completion: ((UserLocalRepositoryResult) -> Void)?)
}

class UserLocalRepository: UserLocalRepositoryProtocol {
    
    let store: CacheStoreProtocol
    init(store: CacheStoreProtocol) {
        self.store = store
    }
    
    func loadUser(withID id: String, completion: @escaping (UserLocalRepositoryResult) -> Void) {
        store.retrieve(withID: id) { result in
            switch result {
            case .empty:
                completion(.empty)
            case .found(let json):
                guard let localDTO = UserLocalDTO.toDTO(fromJson: json) else {
                    completion(.empty)
                    return
                }
                completion(.found(localDTO))
            }
        }
    }
    
    func saveUser(fromRemote user: UserRemoteDTO, completion: ((UserLocalRepositoryResult) -> Void)?) {
        let id = user.id
        guard let json = JSONEncoder().toJson(from: user) else {
            completion?(.encodeError)
            return
        }
        store.insert(withID: id, json: json)
        store.saveToStore { result in
            switch result {
            case .success(()):
                break
            case .failure(_):
                completion?(.saveError)
            }
        }
    }
}
