//
//  ProfileViewController.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/06.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import RxDataSources

class ProfileViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let profileViewModel = ProfileViewModel()
    
    private lazy var myStarRepositoryTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.scrollsToTop = true
    }
    
    var dataSource = RxTableViewSectionedReloadDataSource<UserRepositorySection> { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryTableViewCell", for: indexPath)
        let repositoryTableViewCell = cell as? RepositoryTableViewCell
        repositoryTableViewCell?.setupUI(data: item)
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNotification()
        setupTableView()
        bindAction()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if KeychainManager.shared.readAccessToken(key: "accessToken") == nil {
            self.navigationController?.pushViewController(LoginViewController(), animated: false)
        } else { // login 했을 때
            //FIXME:
//            TabBarController().setTabBarItem()
            let safeAreaTopHeight = view.safeAreaInsets.top

            myStarRepositoryTableView.contentOffset = CGPoint(x: 0, y: -Int(safeAreaTopHeight))
            profileViewModel.initialize()
            profileViewModel.action.fetch.onNext(())
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        setupSubViews()
        setupConstraints()
    }
    
    private func setupSubViews() {
        view.addSubview(myStarRepositoryTableView)
    }
    
    private func setupConstraints() {
        guard let tabBarSize = tabBarController?.tabBar.frame.size.height else {
            return
        }
        myStarRepositoryTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(91)
            $0.bottom.equalToSuperview().inset(tabBarSize)
        }
    }
    
    private func setupNotification() {
        NotificationCenter.default.rx.notification(.logoutSuccess)
            .subscribe(onNext: { [weak self] _ in
                print("logout noti 수신")
                self?.navigationController?.pushViewController(LoginViewController(), animated: false)
            }).disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        myStarRepositoryTableView.showsVerticalScrollIndicator = false
        myStarRepositoryTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        myStarRepositoryTableView.registerCell(cellType: RepositoryTableViewCell.self)
        myStarRepositoryTableView.register(MyStarRepositoryTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID)
    }
    
    private func bindAction() {
        myStarRepositoryTableView.rx.prefetchRows
            .compactMap(\.last?.row)
            .withUnretained(self)
            .bind { [weak self] vc, row in
                if self?.profileViewModel.isRequestCompleted == false {
                    if let dataCount = self?.dataSource.sectionModels.first?.items.count {
                        if row == dataCount - 1 {
                            self?.profileViewModel.action.fetch.onNext(())
                        }
                        print("dataCount: \(dataCount)")
                    }
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    private func bindViewModel() {
        profileViewModel.state.userStarRepositoryData
            .bind(to: myStarRepositoryTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let myStarRepositoryTableViewHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID) as? MyStarRepositoryTableViewHeaderView else {
            return UIView()
        }
        
        profileViewModel.state.userData
            .subscribe(onNext: { data in
                myStarRepositoryTableViewHeaderView.setupUI(data: data)
            }).disposed(by: disposeBag)
        
        return myStarRepositoryTableViewHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 132 : .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
}
