# GitHub_iOS

<img width="120" alt="icon" src="https://user-images.githubusercontent.com/61855905/184266181-04d7d7a6-ae56-41bc-8379-96537505d832.png">
  
</br>  

## [Preview]

### 검색 
<img src="https://user-images.githubusercontent.com/61855905/184260330-28870b89-baca-4814-8f4d-e1a62164f533.gif" width="250" />
</br>

### 로그인, 프로필
<img src="https://user-images.githubusercontent.com/61855905/184260347-157037f0-ebf4-40b3-abcf-7d562baa08e1.gif" width="250" />
</br>

### 스타 동기화 기능
### [star]  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; [unstar]
<img src="https://user-images.githubusercontent.com/61855905/184263815-6290feca-59f9-4c11-8d4a-b6c6d2a3d84b.gif" width="250" />   &nbsp; &nbsp; &nbsp; &nbsp; <img src="https://user-images.githubusercontent.com/61855905/184260894-04c930ac-86a7-4791-b757-8b1cb53b8584.gif" width="250" /> 
</br> 
### Github API 제한 사항
   - Github Search API 호출시, 해당 Repository 에 대한 사용자의 star 여부가 내려오지 않음
   - 이에, Login 한 유저가 star 한 Repository API 와 함께 필터링하여 노출
   - 해당 API 의 한계상 한번에 최대 100개 밖에 가져올 수 없어, 100 개 이상의 데이터가 있는 경우 그 이상의 데이터에 대해 동기화의 정확성을 보장하지 못함

</br>
 

</br>  

  ## [Reference]
 ### Architecture
- MVVM

 ### UI
- SnapKit
- Then
- Kingfisher

 ### Reactive
- RxSwift
- RxCocoa
- RxDataSources

 ### Network
- Moya
