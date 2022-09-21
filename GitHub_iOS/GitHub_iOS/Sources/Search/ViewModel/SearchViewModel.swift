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

final class SearchViewModel : ViewModelType {
    var disposeBag = DisposeBag()
    private(set) var currentPage = 1
    private(set) var perPage = 20
    private(set) var isRequestCompleted = false
    private(set) var section: [UserRepository] = []

    struct Action {
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
                let isRequesting = self.state.isRequesting.value
                if self.isRequestCompleted == false, isRequesting == false {
                    self.requestSearchRepositoryData(query: $0)
                }
            })
            .disposed(by: disposeBag)
    }

    private func requestSearchRepositoryData(query: String) {
        self.state.isRequesting.accept(true)
        APIService.shared.request(GitHubAPI.getSearchRepositoryData(page: currentPage, perPage: perPage, query: query))
            .subscribe(onSuccess: { [weak self] (searchRepository: SearchRepository) in
                self?.process(searchRepository: searchRepository)
                self?.state.isRequesting.accept(false)
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
        
        state.searchRepositoryData.accept([UserRepositorySection(model: Void(), items: section)])
    }
}
