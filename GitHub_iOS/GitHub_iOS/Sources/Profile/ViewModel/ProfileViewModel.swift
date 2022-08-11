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
    private(set) var currentPage = 1
    private(set) var perPage = 20
    private(set) var isRequestCompleted = false
    private(set) var section: [UserRepository] = []
    private(set) var isRequesting = false
    
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
        self.isRequesting = true
        APIService.shared.request(GitHubAPI.getUserData)
            .subscribe(onSuccess: { [weak self] (user: User) in
                self?.state.userData.accept([user.userID: user.userImageURL])
                self?.isRequesting = false
            }, onFailure: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func requestUserStarRepositoryData() {
        self.isRequesting = true
        APIService.shared.request(GitHubAPI.getUserStarRepositoryData(page: currentPage, perPage: perPage))
            .subscribe(onSuccess: { [weak self] (userRepositories: [UserRepository]) in
                self?.process(userRepositories: userRepositories)
                self?.isRequesting = false
            }, onFailure: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    func process(userRepositories: [UserRepository]) {
        if currentPage != 1 {
            isRequestCompleted = userRepositories.isEmpty
        }
        currentPage += 1
        for item in userRepositories {
            section.append(item)
        }
        if isRequestCompleted == false {
            state.userStarRepositoryData.accept([UserRepositorySection(model: Void(), items: section)])
        }
    }
}
