//
//  SearchViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import UIKit

import RxSwift
import RxCocoa
import RxRelay
import Then
import SnapKit

final class SearchViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: SearchViewModel

    private let searchBar = UISearchBar().then {
        $0.searchBarStyle = .minimal
        $0.searchTextField.layer.cornerRadius = 20
    }

    private var searchRepositoryTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.backgroundColor = .white
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

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTableView()
        setupGestureRecognizer(to: searchRepositoryTableView)
        bindAction()
        bindViewModel()
    }

    private func setupView() {
        view.backgroundColor = .white

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
        searchRepositoryTableView.dataSource = self
        searchRepositoryTableView.delegate = self
        searchRepositoryTableView.registerCell(cellType: RepositoryTableViewCell.self)
        searchRepositoryTableView.register(MyStarRepositoryTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID)
    }
    
    private func setupGestureRecognizer(to view: UIView) {
        let tapGestureRecognizer = UITapGestureRecognizer().then {
            $0.cancelsTouchesInView = false
            view.addGestureRecognizer($0)
        }
        
        tapGestureRecognizer.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            })
        .disposed(by: disposeBag)
    }

    private func bindAction() {
        searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] _ in
                self?.viewModel.initialize()
                if let searchText = self?.searchBar.searchTextField.text {
                    self?.searchBar.resignFirstResponder()
                    self?.viewModel.action.didSearch.onNext((searchText))
                }
            }
            .disposed(by: self.disposeBag)

        searchBar.searchTextField.rx.text
            .orEmpty
            .filter { $0.isEmpty }
            .bind { [weak self] _ in
                self?.initializeUI()
            }
            .disposed(by: self.disposeBag)

        searchRepositoryTableView.rx.prefetchRows
            .compactMap(\.last?.row)
            .bind { [weak self] row in
                if let searchText = self?.searchBar.searchTextField.text,
                   let dataCount = self?.viewModel.userRepository.count,
                   row >= dataCount - 3 {
                    self?.viewModel.action.didSearch.onNext((searchText))
                }
            }
            .disposed(by: self.disposeBag)
    }

    private func bindViewModel() {
        viewModel.state.searchRepositoryData
            .subscribe(onNext: { [weak self] _ in
                self?.searchRepositoryTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.state.isRequesting
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isRequesting in
                if isRequesting {
                    self?.showActivityIndicator()
                } else {
                    self?.hideActivityIndicator()
                }
            })
            .disposed(by: disposeBag)
    }

    private func initializeUI() {
        searchBar.searchTextField.text = ""
        viewModel.initialize()
        searchRepositoryTableView.contentOffset = .zero
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

// MARK: UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.userRepository.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(cellType: RepositoryTableViewCell.self, indexPath: indexPath),
              indexPath.item < viewModel.userRepository.count else {
            return UITableViewCell()
        }
        
        cell.configure(viewModel: RepositoryTableViewCellViewModel(data: viewModel.userRepository[indexPath.row],
                                                                   useCase: DefaultStarUseCase(starRepository: DefaultStarRepository()),
                                                                   apiService: APIService()))
        cell.setupUI(data: viewModel.userRepository[indexPath.row], isStarred: false)
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}
