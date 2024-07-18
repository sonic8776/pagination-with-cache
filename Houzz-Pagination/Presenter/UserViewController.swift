//
//  UserViewController.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/2.
//

import UIKit

class UserViewController: UIViewController {
    
    lazy var viewModel = makeViewModel()
    lazy var tableView = makeTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadUsers()
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
}

private extension UserViewController {
    func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: .init(describing: UITableViewCell.self))
        return tableView
    }
    
    func makeViewModel() -> UserViewModel {
        let client = URLSessionHTTPClient(session: .shared)
        let remoteRepo = UserRemoteRepository(client: client)
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("users.json")
        let store = CacheStore(storeURL: storeURL)
        let imageStoreURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("imageFileNames.json")
        let imageStore = ImageCacheStore(storeURL: imageStoreURL)
        let localRepo = UserLocalRepository(store: store, imageStore: imageStore)
        let useCase = UserUseCase(remoteRepo: remoteRepo, localRepo: localRepo)
        let viewModel = UserViewModel(useCase: useCase)
        viewModel.delegate = self
        return viewModel
    }
}

extension UserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .init(describing: UITableViewCell.self), for: indexPath)
        let fullName = viewModel.users[indexPath.row].firstName + " " + viewModel.users[indexPath.row].lastName
        cell.textLabel?.text = fullName
        cell.imageView?.image = viewModel.users[indexPath.row].image
        return cell
    }
}

extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
            viewModel.loadUsers()
        }
    }
}

extension UserViewController: UserViewModelDelegate {
    func userViewModel(_ userViewModel: UserViewModel, userDidUpdate users: [User]) {
        tableView.reloadData()
        viewModel.didFinishLoading()
    }
}
