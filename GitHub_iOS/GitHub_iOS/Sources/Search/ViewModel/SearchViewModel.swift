//
//  SearchViewModel.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/10.
//

import Foundation

import RxSwift
import RxRelay
import RxDataSources

class SearchViewModel : ViewModelType {
    var disposeBag = DisposeBag()
    var currentPage = 1
    var perPage = 20
    var isRequestCompleted = false
    var section: [UserRepository] = []
    var starredList: [UserRepository] = []
    var isViewWillDisappear = false
    var isRequesting = false
    
    struct Action {
        let viewWillAppear = PublishSubject<Void>()
        let viewDisappear = PublishSubject<Void>()
        let didSearch = PublishSubject<String>()
    }

    struct State {
        let searchRepositoryData = BehaviorRelay(value: [UserRepositorySection]())
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
        state.searchRepositoryData.accept([UserRepositorySection(model: Void(), items: section)])
    }
    
    private func configure() {
        action.didSearch
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                guard self.isViewWillDisappear == false else { return }

                if self.section.count == 0,
                   KeychainManager.shared.readAccessToken(key: "accessToken") != nil {
                    self.isRequesting = true
                    Single.zip(APIService.shared.request(GitHubAPI.getUserStarRepositoryData(page: 1, perPage: 100)),
                               APIService.shared.request(GitHubAPI.getSearchRepositoryData(page: self.currentPage, perPage: self.perPage, query: $0))) { [weak self] (starredRepos: [UserRepository], searchRepoData: SearchRepository) in
                        self?.starredList = starredRepos
//                        print("[jeon] SearchStarList: \(starredRepos.map { $0.fullName })")
                        self?.process(searchRepoData: searchRepoData)
                    }
                    .subscribe(onSuccess: { [weak self] _ in
                        self?.isRequesting = false
                    }, onFailure: {
                        print($0)
                    })
                    .disposed(by: self.disposeBag)
                } else {
                    self.requestSearchRepositoryData(query: $0)
                }
            })
            .disposed(by: disposeBag)

        action.viewDisappear
            .subscribe(onNext: { [weak self] _ in
                self?.isViewWillDisappear = true
                // 네트워크 요청 진행중 task cancel
                print("network")
            })
            .disposed(by: disposeBag)
        
        action.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                self?.isViewWillDisappear = false
            })
            .disposed(by: disposeBag)
    }

    private func requestSearchRepositoryData(query: String) {
        isRequesting = true
        APIService.shared.request(GitHubAPI.getSearchRepositoryData(page: currentPage, perPage: perPage, query: query))
            .subscribe(onSuccess: { [weak self] (searchRepoData: SearchRepository) in
                self?.process(searchRepoData: searchRepoData)
                self?.isRequesting = false
            }, onFailure: {
                print($0)
            })
            .disposed(by: disposeBag)
    }

    private func process(searchRepoData: SearchRepository) {
        for item in searchRepoData.items {
            section.append(item)
        }
        isRequestCompleted = searchRepoData.totalCount <= section.count
        currentPage += 1
        
        if isViewWillDisappear == false {
            state.searchRepositoryData.accept([UserRepositorySection(model: Void(), items: section)])
        }
    }
}
