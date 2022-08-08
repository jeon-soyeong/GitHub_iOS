//
//  MyStarRepositoryTableViewHeaderView.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/08.
//

import UIKit

final class MyStarRepositoryTableViewHeaderView: UITableViewHeaderFooterView {
    static let headerViewID = "MyStarRepositoryTableViewHeaderView"

    private let userImageView = UIImageView().then {
        //FIXME: test 후 지우기
        $0.image = UIImage(named: "testImage")
        $0.layer.cornerRadius = 45
        $0.layer.masksToBounds = true
    }

    private let userIDLabel = UILabel().then {
        $0.text = "userID"
        $0.font = UIFont.setFont(type: .medium, size: 28)
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = .white
        setupSubViews()
        setupConstraints()
    }

    private func setupSubViews() {
        self.addSubviews([userImageView, userIDLabel])
    }

    private func setupConstraints() {
        userImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(24)
            $0.width.height.equalTo(90)
        }

        userIDLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(userImageView.snp.trailing).offset(24)
        }
    }
}
