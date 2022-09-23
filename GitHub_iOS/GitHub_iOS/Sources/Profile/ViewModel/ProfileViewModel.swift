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

final class ProfileViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    private(set) var currentPage = 1
    private(set) var perPage = 20
    private(set) var isRequestCompleted = false
    private(set) var section: [UserRepository] = []
    private let apiService: APIService
    
    struct Action {
        let fetch = PublishSubject<Void>()
    }
    
    struct State {
        let userData = BehaviorRelay(value: [String: String]())
        let userStarRepositoryData = BehaviorRelay(value: [UserRepositorySection]())
        let isRequesting = BehaviorRelay<Bool>(value: false)
    }
    
    var action = Action()
    var state = State()
    
    init(apiService: APIService) {
        self.apiService = apiService
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
                guard let self = self else { return }
                let isRequesting = self.state.isRequesting.value
                if isRequesting == false {
                    if self.section.count == 0 {
                        self.state.isRequesting.accept(true)
                        Single.zip(self.apiService.request(GitHubAPI.getUserData),
                                   self.apiService.request(GitHubAPI.getUserStarRepositoryData(page: self.currentPage, perPage: self.perPage))) { [weak self] (user: User, userRepositories: [UserRepository]) in
                            self?.state.userData.accept([user.userID: user.userImageURL])
                            self?.process(userRepositories: userRepositories)
                        }
                       .subscribe(onSuccess: { [weak self] _ in
                           self?.state.isRequesting.accept(false)
                       }, onFailure: {
                           print($0)
                       })
                       .disposed(by: self.disposeBag)
                    } else {
                        if self.isRequestCompleted == false {
                            self.requestUserStarRepositoryData()
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func requestUserStarRepositoryData() {
        self.state.isRequesting.accept(true)
        apiService.request(GitHubAPI.getUserStarRepositoryData(page: currentPage, perPage: perPage))
            .subscribe(onSuccess: { [weak self] (userRepositories: [UserRepository]) in
                self?.process(userRepositories: userRepositories)
                self?.state.isRequesting.accept(false)
            }, onFailure: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
    
    func process(userRepositories: [UserRepository]) {
        if currentPage != 1 {
            isRequestCompleted = userRepositories.isEmpty
        }
        
        if isRequestCompleted == false {
            for item in userRepositories {
                section.append(item)
            }
            currentPage += 1
            state.userStarRepositoryData.accept([UserRepositorySection(model: Void(), items: section)])
        }
    }
}
