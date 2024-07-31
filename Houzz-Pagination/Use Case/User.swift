//
//  User.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/17.
//

import Foundation

struct User {
    
    let id: String
    let firstName: String
    let lastName: String
    var imageData: Data? // Data -> cross platform (platform agnostic), UIKit is only for iOS. Convert to UIImage in ViewModel
    
    init(fromRemoteDTO dto: UserRemoteDTO) {
        self.id = dto.id
        self.firstName = dto.firstName
        self.lastName = dto.lastName
    }
    
    init(fromLocalDTO dto: UserLocalDTO) {
        self.id = dto.id
        self.firstName = dto.firstName
        self.lastName = dto.lastName
    }
}
