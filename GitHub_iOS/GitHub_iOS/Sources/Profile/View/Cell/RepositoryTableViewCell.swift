//
//  RepositoryTableViewCell.swift
//  GitHub_iOS
//
//  Created by 전소영 on 2022/08/08.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {
    //FIXME: viewmodel data 로 변경
    let data: [String] = ["reactorkit", "swift", "ios", "reactive", "observer", "functional"]
    private var dataCount = 0
    private let contentsLimitWidth = UIScreen.main.bounds.width - 100
    
    private let repositoryImageView = UIImageView().then {
        $0.image = UIImage(named: "repository")
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let ownerNameLabel = UILabel().then {
        $0.textColor = .mainBlue
        $0.font = UIFont.setFont(type: .regular, size: 18)
    }
    
    private let repositoryNameLabel = UILabel().then {
        $0.textColor = .mainBlue
        $0.font = UIFont.setFont(type: .bold, size: 18)
    }
    
    private let repositoryDescriptionLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.setFont(type: .regular, size: 14)
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let starImageView = UIImageView().then {
        $0.image = UIImage(named: "unStar")
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
    
    private let LanguageView = UIView().then {
        $0.layer.cornerRadius = 7
        $0.backgroundColor = .mainBlue
    }
    
    private let LanguageLabel = UILabel().then {
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
    
    private func setupView() {
        setupSubViews()
        setupConstraints()
    }
    
    private func setupSubViews() {
        self.addSubviews([repositoryImageView, ownerNameLabel, repositoryNameLabel, starImageView, repositoryDescriptionLabel, repositoryTopicCollectionView, starCountImageView, starCountLabel, LanguageView, LanguageLabel])
    }
    
    private func setupConstraints() {
        repositoryImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.equalToSuperview().inset(14)
            $0.width.height.equalTo(18)
        }
        
        ownerNameLabel.snp.makeConstraints {
            $0.top.equalTo(repositoryImageView.snp.top)
            $0.leading.equalTo(repositoryImageView.snp.trailing).offset(6)
        }
        
        repositoryNameLabel.snp.makeConstraints {
            $0.top.equalTo(repositoryImageView.snp.top)
            $0.leading.equalTo(ownerNameLabel.snp.trailing)
        }
        
        starImageView.snp.makeConstraints {
            $0.top.equalTo(repositoryImageView.snp.top)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }
        
        repositoryDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(ownerNameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(ownerNameLabel.snp.leading)
            $0.width.equalTo(contentsLimitWidth)
        }
        
        repositoryTopicCollectionView.snp.makeConstraints {
            $0.top.equalTo(repositoryDescriptionLabel.snp.bottom).offset(2)
            $0.leading.equalTo(ownerNameLabel.snp.leading)
            $0.width.equalTo(contentsLimitWidth)
            $0.height.equalTo(24)
        }
        
        starCountImageView.snp.makeConstraints {
            $0.leading.equalTo(ownerNameLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(14)
        }
        
        starCountLabel.snp.makeConstraints {
            $0.leading.equalTo(starCountImageView.snp.trailing).offset(4)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        LanguageView.snp.makeConstraints {
            $0.leading.equalTo(starCountLabel.snp.trailing).offset(12)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(14)
        }
        
        LanguageLabel.snp.makeConstraints {
            $0.leading.equalTo(LanguageView.snp.trailing).offset(4)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func setupCollectionView() {
        repositoryTopicCollectionView.dataSource = self
        repositoryTopicCollectionView.delegate = self
        repositoryTopicCollectionView.registerCell(cellType: RepositoryTopicCollectionViewCell.self)
    }
    
    private func calculateCellWidth(index: Int, fontSize: CGFloat) -> CGFloat {
        let label = UILabel()
        //FIXME: viewModel data로 변경
        label.text = data[index]
        label.font = UIFont.setFont(type: .medium, size: fontSize)
        label.sizeToFit()
        return label.frame.width
    }
    
    private func calculateFirstLineLastCellIndex(dataCount: Int) -> Int {
        var totalCellWidth: CGFloat = 0
        var resultIndex = 0
        for i in 0..<dataCount {
            let cellWidth = calculateCellWidth(index: i, fontSize: 12) + 10 + 4
            totalCellWidth += cellWidth
            if totalCellWidth >= contentsLimitWidth {
                resultIndex = i - 1
                break
            }
        }
        return resultIndex
    }
    
    //FIXME: viewModel data로 변경
    func setupUI(index: Int) {
        ownerNameLabel.text = "tableViewcell test\(index)"
        repositoryNameLabel.text = "WeatherLook_iOS"
        repositoryDescriptionLabel.text = "WeatherLook_iOSWeatherLook_WeatherLook_iOSWeatherLook_WeatherLook_iOSWeatherLook_WeatherLook_iOS"
        starCountLabel.text = "881"
        LanguageLabel.text = "Swift"
    }
}

// MARK: UICollectionViewDataSource
extension RepositoryTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calculateFirstLineLastCellIndex(dataCount: data.count) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let repositoryTopicCollectionViewCell = collectionView.dequeueReusableCell(cellType: RepositoryTopicCollectionViewCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        repositoryTopicCollectionViewCell.setupUI(topic: data[indexPath.item])
        
        return repositoryTopicCollectionViewCell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension RepositoryTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = calculateCellWidth(index: indexPath.item, fontSize: 12)
        return CGSize(width: cellWidth + 10, height: 24)
    }
}
