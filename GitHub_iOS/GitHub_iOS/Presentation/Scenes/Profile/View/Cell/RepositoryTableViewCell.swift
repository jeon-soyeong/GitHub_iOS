//
//  RepositoryTableViewCell.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/08.
//

import UIKit

import RxSwift
import Kingfisher
import RxRelay
import RxCocoa

final class RepositoryTableViewCell: UITableViewCell {
    private let disposeBag = DisposeBag()
    private let contentsLimitWidth = UIScreen.main.bounds.width - 100
    private var viewModel: RepositoryTableViewCellViewModel?
    private var dataCount = 0
    private var userRepositoryData: UserRepository?

    private let repositoryOwnerImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
        $0.layer.cornerRadius = 9
        $0.layer.masksToBounds = true
        $0.addBorder(color: .lightGray, width: 0.5)
        $0.addShadow()
    }

    private let ownerNameLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.font = UIFont.setFont(type: .regular, size: 18)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    private let repositoryNameLabel = UILabel().then {
        $0.textColor = .mainBlue
        $0.font = UIFont.setFont(type: .bold, size: 18)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    private let repositoryDescriptionLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.setFont(type: .regular, size: 14)
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
    }

    private let starButton = UIButton().then {
        $0.setImage(UIImage(named: "star"), for: .selected)
        $0.setImage(UIImage(named: "unStar"), for: .normal)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }

    private let repositoryTopicCollectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 4
        $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    private lazy var repositoryTopicCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: repositoryTopicCollectionViewFlowLayout).then {
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.backgroundColor = .systemBackground
    }

    private let starCountImageView = UIImageView().then {
        $0.image = UIImage(named: "starCount")
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }

    private let starCountLabel = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.setFont(type: .regular, size: 12)
    }

    private let languageView = UIView().then {
        $0.layer.cornerRadius = 7
    }

    private let languageLabel = UILabel().then {
        $0.textColor = .gray
        $0.font = UIFont.setFont(type: .regular, size: 12)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: RepositoryTableViewCellViewModel) {
        self.viewModel = viewModel
        bindAction()
        bindViewModel()
        viewModel.action.fetchTopics.onNext(())
    }

    private func setupView() {
        setupSubViews()
        setupConstraints()
    }

    private func setupSubViews() {
        contentView.addSubviews([repositoryOwnerImageView, ownerNameLabel, repositoryNameLabel, starButton, repositoryDescriptionLabel, repositoryTopicCollectionView, starCountImageView, starCountLabel, languageView, languageLabel])
    }

    private func setupConstraints() {
        repositoryOwnerImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalToSuperview().inset(14)
            $0.width.height.equalTo(18)
        }

        ownerNameLabel.snp.makeConstraints {
            $0.top.equalTo(repositoryOwnerImageView.snp.top).offset(-1)
            $0.leading.equalTo(repositoryOwnerImageView.snp.trailing).offset(6)
            $0.width.equalTo(contentsLimitWidth)
        }

        repositoryNameLabel.snp.makeConstraints {
            $0.top.equalTo(ownerNameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(ownerNameLabel.snp.leading)
            $0.width.equalTo(contentsLimitWidth)
        }

        starButton.snp.makeConstraints {
            $0.top.equalTo(repositoryOwnerImageView.snp.top)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }

        repositoryDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(repositoryNameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(repositoryNameLabel.snp.leading)
            $0.width.equalTo(contentsLimitWidth)
        }

        repositoryTopicCollectionView.snp.makeConstraints {
            $0.top.equalTo(repositoryDescriptionLabel.snp.bottom).offset(2)
            $0.leading.equalTo(repositoryNameLabel.snp.leading)
            $0.width.equalTo(contentsLimitWidth)
            $0.height.equalTo(24)
        }

        starCountImageView.snp.makeConstraints {
            $0.leading.equalTo(repositoryNameLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(14)
        }

        starCountLabel.snp.makeConstraints {
            $0.leading.equalTo(starCountImageView.snp.trailing).offset(4)
            $0.bottom.equalToSuperview().inset(10)
        }

        languageView.snp.makeConstraints {
            $0.leading.equalTo(starCountLabel.snp.trailing).offset(12)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(14)
        }

        languageLabel.snp.makeConstraints {
            $0.leading.equalTo(languageView.snp.trailing).offset(4)
            $0.bottom.equalToSuperview().inset(10)
        }
    }

    private func setupCollectionView() {
        repositoryTopicCollectionView.delegate = self
        repositoryTopicCollectionView.dataSource = self
        repositoryTopicCollectionView.registerCell(cellType: RepositoryTopicCollectionViewCell.self)
    }

    private func bindAction() {
        starButton.rx.tap
            .bind { [weak self] in
                guard let self = self,
                      let fullName = self.userRepositoryData?.fullName else { return }
                self.viewModel?.action.didTappedStarButton.onNext((!self.starButton.isSelected, fullName))
            }
            .disposed(by: disposeBag)
    }

    private func bindViewModel() {
        viewModel?.state.topicsData
            .subscribe(onNext: { [weak self] _ in
                self?.repositoryTopicCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel?.state.starToggleResult
            .subscribe(onNext: { [weak self] isSuccess in
                guard let self = self,
                      isSuccess else { return }
                self.starButton.isSelected = !self.starButton.isSelected
            })
            .disposed(by: disposeBag)
    }

    private func convertAbbreviation(to number: Int) -> String {
        let number = Double(number)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(round(million * 10) / 10)M"
        } else if thousand >= 1.0 {
            return "\(round(thousand * 10) / 10)K"
        } else {
            return "\(Int(number))"
        }
    }

    private func getLanguageViewColor(language: String) -> UIColor {
        switch language {
        case LanguageType.objectivec.text:
            return LanguageType.objectivec.color
        case LanguageType.java.text:
            return LanguageType.java.color
        case LanguageType.javaScript.text:
            return LanguageType.javaScript.color
        case LanguageType.python.text:
            return LanguageType.python.color
        case LanguageType.starlark.text:
            return LanguageType.starlark.color
        case LanguageType.go.text:
            return LanguageType.go.color
        case LanguageType.shell.text:
            return LanguageType.shell.color
        case LanguageType.ruby.text:
            return LanguageType.ruby.color
        case LanguageType.kotlin.text:
            return LanguageType.kotlin.color
        case LanguageType.php.text:
            return LanguageType.php.color
        case LanguageType.applescript.text:
            return LanguageType.applescript.color
        case LanguageType.vue.text:
            return LanguageType.vue.color
        case LanguageType.css.text:
            return LanguageType.css.color
        default:
            return LanguageType.swift.color
        }
    }

    func setupUI(data: UserRepository, isStarred: Bool) {
        userRepositoryData = data
        starButton.isHidden = !isStarred
        starButton.isSelected = isStarred
        repositoryOwnerImageView.kf.setImage(with: URL(string: data.owner.avatarURL))
        ownerNameLabel.text = data.owner.login
        repositoryNameLabel.text = data.name
        repositoryDescriptionLabel.text = data.userRepositoryDescription
        starCountLabel.text = convertAbbreviation(to: data.stargazersCount)
        if let language = data.language {
            languageView.backgroundColor = getLanguageViewColor(language: language)
            languageLabel.text = data.language
        }
    }
}

// MARK: UICollectionViewDataSource
extension RepositoryTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.topics.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(cellType: RepositoryTopicCollectionViewCell.self, indexPath: indexPath),
              let topics = viewModel?.topics,
              indexPath.item < topics.count else {
            return UICollectionViewCell()
        }
        cell.setupUI(topic: topics[indexPath.item])
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension RepositoryTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = viewModel?.calculateCellWidth(index: indexPath.item, fontSize: 12) ?? 0
        let cellPadding = 12
        return CGSize(width: Int(cellWidth) + cellPadding, height: 24)
    }
}
