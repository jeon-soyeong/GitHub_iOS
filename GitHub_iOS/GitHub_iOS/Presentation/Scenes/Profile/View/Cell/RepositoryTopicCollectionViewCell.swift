//
//  RepositoryTopicCollectionViewCell.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/08.
//

import UIKit

final class RepositoryTopicCollectionViewCell: UICollectionViewCell {
    private let repositoryTopicLabelView = UIView().then {
        $0.backgroundColor = .mainSkyBlue
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 6
    }

    private let repositoryTopicLabel = UILabel().then {
        $0.textColor = .mainBlue
        $0.font = UIFont.setFont(type: .medium, size: 12)
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.addSubview(repositoryTopicLabelView)
        repositoryTopicLabelView.addSubview(repositoryTopicLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        repositoryTopicLabelView.snp.makeConstraints {
            $0.centerX.centerY.width.equalToSuperview()
            $0.height.equalTo(14)
        }

        repositoryTopicLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

    func setupUI(topic: String) {
        repositoryTopicLabel.text = topic
    }
}
