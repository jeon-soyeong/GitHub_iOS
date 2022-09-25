//
//  SearchViewModel.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/10.
//

import Foundation

import RxSwift
import RxRelay

final class SearchViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    private let apiService: APIService
    private(set) var currentPage = 1
    private(set) var perPage = 20
    private(set) var isRequestCompleted = false
    private(set) var userRepository: [UserRepository] = []

    struct Action {
        let didSearch = PublishSubject<String>()
    }

    struct State {
        let searchRepositoryData = BehaviorRelay(value: [UserRepository]())
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
        userRepository = []
        state.searchRepositoryData.accept([])
    }

    private func configure() {
        action.didSearch
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let isRequesting = self.state.isRequesting.value
                if self.isRequestCompleted == false, isRequesting == false {
                    self.requestSearchRepositoryData(query: $0)
                }
            })
            .disposed(by: disposeBag)
    }

    private func requestSearchRepositoryData(query: String) {
        self.state.isRequesting.accept(true)
        apiService.request(GitHubAPI.getSearchRepositoryData(page: currentPage, perPage: perPage, query: query))
            .subscribe(onSuccess: { [weak self] (repositoryInfo: RepositoryInfo) in
                self?.process(repositoryInfo: repositoryInfo)
                self?.state.isRequesting.accept(false)
            }, onFailure: {
                print($0)
            })
            .disposed(by: disposeBag)
    }

    private func process(repositoryInfo: RepositoryInfo) {
        for item in repositoryInfo.items {
            userRepository.append(item)
        }
        isRequestCompleted = repositoryInfo.totalCount <= userRepository.count
        currentPage += 1
        
        state.searchRepositoryData.accept(userRepository)
    }
}
