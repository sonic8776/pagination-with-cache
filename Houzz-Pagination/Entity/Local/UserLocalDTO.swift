//
//  UserLocalDTO.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/17.
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
