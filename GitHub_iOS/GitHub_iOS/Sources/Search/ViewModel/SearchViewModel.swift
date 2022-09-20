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
    private(set) var currentPage = 1
    private(set) var perPage = 20
    private(set) var isRequestCompleted = false
    private(set) var section: [UserRepository] = []
    private(set) var starredList: [UserRepository] = []
    private(set) var isViewWillDisappear = false
    private(set) var isRequesting = false

    struct Action {
        let viewWillAppear = PublishSubject<Void>()
        let viewDisappear = PublishSubject<Void>()
        let didSearch = PublishSubject<String>()
    }

    struct State {
        let searchRepositoryData = BehaviorRelay(value: [UserRepositorySection]())
        let isRequesting = BehaviorRelay<Bool>(value: false)
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
                               APIService.shared.request(GitHubAPI.getSearchRepositoryData(page: self.currentPage, perPage: self.perPage, query: $0))) { [weak self] (starredRepository: [UserRepository], searchRepository: SearchRepository) in
                        self?.starredList = starredRepository
                        self?.process(searchRepository: searchRepository)
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
            .subscribe(onSuccess: { [weak self] (searchRepository: SearchRepository) in
                self?.process(searchRepository: searchRepository)
                self?.isRequesting = false
            }, onFailure: {
                print($0)
            })
            .disposed(by: disposeBag)
    }

    private func process(searchRepository: SearchRepository) {
        for item in searchRepository.items {
            section.append(item)
        }
        isRequestCompleted = searchRepository.totalCount <= section.count
        currentPage += 1
        
        if isViewWillDisappear == false {
            state.searchRepositoryData.accept([UserRepositorySection(model: Void(), items: section)])
        }
    }
}
