//
//  RepositoryTableViewCellViewModel.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/10.
//

import Foundation

import RxSwift

class RepositoryTableViewCellViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    struct Action {
        let didTappedStarButton = PublishSubject<(isRequestStar: Bool, fullName: String)>()
    }
    
    struct State {
        let starToggleResult = BehaviorSubject<Bool>(value: false)
    }
    
    var action = Action()
    var state = State()
    
    init() {
        self.configure()
    }
    
    private func configure() {
        action.didTappedStarButton
            .subscribe(onNext: { [weak self] result in
                if result.isRequestStar {
                    self?.requestStar(fullName: result.fullName)
                } else {
                    self?.requestUnstar(fullName: result.fullName)
                }
            })
            .disposed(by: disposeBag)
    }

    private func requestStar(fullName: String) {
        APIService.shared.request(GitHubAPI.requestStar(fullName: fullName))
            .subscribe(onNext: { [weak self] in
                self?.state.starToggleResult.onNext($0.count == 0)
            }, onError: { [weak self] _ in
                self?.state.starToggleResult.onNext(false)
            })
            .disposed(by: disposeBag)
    }

    private func requestUnstar(fullName: String) {
        APIService.shared.request(GitHubAPI.requestUnstar(fullName: fullName))
            .subscribe(onNext: { [weak self] in
                self?.state.starToggleResult.onNext($0.count == 0)
            }, onError: { [weak self] _ in
                self?.state.starToggleResult.onNext(false)
            })
            .disposed(by: disposeBag)
    }
}