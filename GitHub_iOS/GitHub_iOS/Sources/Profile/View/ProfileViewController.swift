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

class ProfileViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private lazy var myStarRepositoryTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNotification()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if KeychainManager.shared.readAccessToken(key: "accessToken") == nil {
            self.navigationController?.pushViewController(LoginViewController(), animated: false)
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
            $0.top.leading.trailing.equalToSuperview()
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
        myStarRepositoryTableView.dataSource = self
        myStarRepositoryTableView.delegate = self
        
        myStarRepositoryTableView.showsVerticalScrollIndicator = false
        myStarRepositoryTableView.registerCell(cellType: RepositoryTableViewCell.self)
        myStarRepositoryTableView.register(MyStarRepositoryTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID)
    }
}

// MARK: UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //FIXME: viewModel data 로 변경
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let repositoryTableViewCell = tableView.dequeueReusableCell(cellType: RepositoryTableViewCell.self, indexPath: indexPath) else {
            return UITableViewCell()
        }
        repositoryTableViewCell.setupUI(index: indexPath.row)
        return repositoryTableViewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

// MARK: UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let myStarRepositoryTableViewHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyStarRepositoryTableViewHeaderView.headerViewID) as? MyStarRepositoryTableViewHeaderView else {
            //TODO: myStarRepositoryTableViewHeaderView UI udate
            //            myStarRepositoryTableViewHeaderView.userIDLabel
            
            return UIView()
        }
        
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
