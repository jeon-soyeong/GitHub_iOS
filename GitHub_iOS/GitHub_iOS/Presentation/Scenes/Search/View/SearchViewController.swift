//
//  SearchViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import UIKit

import ReactorKit
import Then
import SnapKit

final class SearchViewController: UIViewController, View {
    var disposeBag = DisposeBag()

    private let searchBar = UISearchBar().then {
        $0.searchBarStyle = .minimal
        $0.searchTextField.layer.cornerRadius = 20
    }

    private var searchRepositoryTableView = UITableView(frame: CGRect.zero).then {
        $0.backgroundColor = .systemBackground
        $0.clipsToBounds = true
        $0.scrollsToTop = true
        $0.isUserInteractionEnabled = true
        $0.keyboardDismissMode = .onDrag
    }
    
    private lazy var loadingIndicatorView = LoadingIndicatorView().then {
        $0.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        $0.center = view.center
        $0.isHidden = true
    }

    init(reactor: SearchReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTableView()
        setupGestureRecognizer(to: searchRepositoryTableView)
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        setupSubViews()
        setupConstraints()
    }

    private func setupSubViews() {
        view.addSubviews([searchBar, searchRepositoryTableView, loadingIndicatorView])
    }

    private func setupConstraints() {
        searchBar.snp.makeConstraints {
            $0.top.equalToSuperview().inset(120)
            $0.width.equalToSuperview().inset(18)
            $0.centerX.equalToSuperview()
        }

        searchRepositoryTableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(tabBarController?.tabBar.frame.size.height ?? 100)
        }
    }

    private func setupTableView() {
        searchRepositoryTableView.showsVerticalScrollIndicator = false
        searchRepositoryTableView.delegate = self
        searchRepositoryTableView.registerCell(cellType: RepositoryTableViewCell.self)
        searchRepositoryTableView.register(MyStarRepositoryTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID)
    }
    
    private func setupGestureRecognizer(to view: UIView) {
        let tapGestureRecognizer = UITapGestureRecognizer().then {
            view.addGestureRecognizer($0)
        }
        
        tapGestureRecognizer.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            })
        .disposed(by: disposeBag)
    }

    func bind(reactor: SearchReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }

    private func bindAction(reactor: SearchReactor) {
        typealias Action = SearchReactor.Action

        searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .do(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            })
            .map { Action.didSearch(self.searchBar.searchTextField.text) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        searchBar.searchTextField.rx.text
            .orEmpty
            .filter { $0.isEmpty }
            .do(onNext: { [weak self] _ in
                self?.searchBar.searchTextField.text = ""
                self?.searchRepositoryTableView.contentOffset = .zero
            })
            .map { _ in Action.initialize }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        searchRepositoryTableView.rx.prefetchRows
            .filter { $0.contains(where: { $0.row >= reactor.currentState.searchRepositories.count - 3 }) }
            .map { _ in Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }

    private func bindState(reactor: SearchReactor) {
        reactor.state
            .map { $0.searchRepositories }
            .observe(on: MainScheduler.instance)
            .bind(to: searchRepositoryTableView.rx.items(cellIdentifier: RepositoryTableViewCell.identifier, cellType: RepositoryTableViewCell.self)) { row, userRepository, cell in
                cell.configure(reactor: RepositoryTableViewCellReactor(data: userRepository,
                                                                       useCase: DefaultStarUseCase(starRepository: DefaultStarRepository()),
                                                                       apiService: APIService()))
                cell.setupUI(data: userRepository, isStarred: false)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.noSearchResult }
            .filter { $0 == true }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showAlert(title: "검색 결과 없음 ❌", message: "검색 결과가 없으므로 다른 키워드로 검색 바랍니다.")
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isLoading }
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showActivityIndicator()
                } else {
                    self?.hideActivityIndicator()
                }
            })
            .disposed(by: disposeBag)
    }

    private func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = false
            self.loadingIndicatorView.startAnimation()
        }
    }

    private func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingIndicatorView.isHidden = true
        }
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
}
