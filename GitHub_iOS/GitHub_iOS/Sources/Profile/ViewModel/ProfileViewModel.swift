//
//  ProfileViewModel.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/09.
//

import Foundation

import RxSwift
import RxRelay
import RxDataSources

typealias UserRepositorySection = SectionModel<Void, UserRepository>

class ProfileViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    var currentPage = 1
    var perPage = 20
    var isRequestCompleted = false
    var section: [UserRepository] = []
    
    struct Action {
        let fetch = PublishSubject<Void>()
    }
    
    struct State {
        let userData = BehaviorRelay(value: [String: String]())
        let userStarRepositoryData = BehaviorRelay(value: [UserRepositorySection]())
    }
    
    var action = Action()
    var state = State()
    
    init() {
        self.configure()
    }
    
    // refresh 할 때만
    func initialize() {
        currentPage = 1
        isRequestCompleted = false
        section = []
    }
    
    private func configure() {
        action.fetch
            .subscribe(onNext: { [weak self] in
                self?.requestUserData()
                self?.requestUserStarRepositoryData()
            })
            .disposed(by: disposeBag)
    }
    
    private func requestUserData() {
        APIService.shared.request(GitHubAPI.getUserData)
            .subscribe(onSuccess: { [weak self] (user: User) in
                self?.state.userData.accept([user.userID: user.userImageURL])
            }, onFailure: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func requestUserStarRepositoryData() {
        APIService.shared.request(GitHubAPI.getUserStarRepositoryData(page: currentPage, perPage: perPage))
            .subscribe(onSuccess: { [weak self] (userRepositories: [UserRepository]) in
//                print("[jeon] UserRepositories: \(userRepositories.map { $0.fullName })")
                if self?.currentPage != 1 {
                    self?.isRequestCompleted = userRepositories.isEmpty
                }
                self?.currentPage += 1
                for item in userRepositories {
                    self?.section.append(item)
                }
                if self?.isRequestCompleted == false {
                    if let section = self?.section {
                        self?.state.userStarRepositoryData.accept([UserRepositorySection(model: Void(), items: section)])
                    }
                }
            }, onFailure: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
}
