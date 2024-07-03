//
//  UserViewModel.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import Foundation

enum UserViewModelError: Error {
    case viewModelError
}

protocol UserViewModelDelegate: AnyObject {
    func userViewModel(_ userViewModel: UserViewModel, userDidUpdate users: [User])
}

class UserViewModel {
    
    let useCase: UserUseCaseProtocol
    
    weak var delegate: UserViewModelDelegate?
    
    private(set) var users = [User]()
    private var page = 0
    private let limit = 10
    private var isLoadingUser = false
    
    init(useCase: UserUseCaseProtocol) {
        self.useCase = useCase
    }
    
    func didFinishLoading() {
        isLoadingUser = false
    }
    
    func loadUsers() {
        if isLoadingUser { return }
        isLoadingUser = true
        page += 1
        if page > limit {
            return
        }
        useCase.loadUser(fromPage: page) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users += users
                    self.delegate?.userViewModel(self, userDidUpdate: self.users)
                case .failure(let error):
                    break
                }
            }
            
        }
    }
}
