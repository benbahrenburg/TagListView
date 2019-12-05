//
//  UserProfileViewModel.swift
//  Crowdswap
//
//  Created by Daniel Marulanda on 7/19/19.
//  Copyright © 2019 Crowdswap, Inc. All rights reserved.
//
import RxCocoa
import RxSwift
import RxKingfisher
import Differentiator
import TagListView
struct UserProfileViewModel {

  let username: Driver<String>
  let about: Driver<String>
  let profileImageUrl: Driver<URL?>
  let swapsQty: Driver<String>
  let isVerified: Driver<Bool>
  let reputationNumber: Driver<String>
  let userInterest: Observable<[InterestInfo]>

  init (user: Observable<SwapperInfo>) {
    self.swapsQty = user.map { $0.countSwaps ?? "0" }.asDriver(onErrorJustReturn: "")
    self.reputationNumber = user.map { $0.reputationNumber ?? "0" }.asDriver(onErrorJustReturn: "")
    self.about = user.map { $0.bio?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "I'm still thinking on my bio" }
      .asDriver(onErrorJustReturn: "I'm still thinking on my bio")
    self.username = user.map { $0.username }.asDriver(onErrorJustReturn: "")
    self.isVerified = user.map { $0.isVerified ?? false }.asDriver(onErrorJustReturn: false)
    self.profileImageUrl = user.map { user in
      return URL(string: user.profilePicture ?? "https://images.crowdswap.com/octavio.png") }
      .asDriverOnErrorJustComplete()
    self.userInterest = user
      .map { $0.followInterestsBySwapperId.nodes.compactMap { ($0?.interestByInterestId?.fragments.interestInfo) }  }
  }
}

class UserProfileView: UICollectionReusableView {
  private(set) var disposeBag = DisposeBag()
  var viewModel: UserProfileViewModel!

  @IBOutlet weak var tagList: TagListView! {
    didSet {
      tagList.alignment = .left
      tagList.wrapTagsToNextRow = false
    }
  }
  @IBOutlet weak var swapsQtyLabel: UILabel!
  @IBOutlet weak var praiseQtyLabel: UILabel!
  @IBOutlet weak var isVerifiedIcon: UIImageView!
  @IBOutlet weak var profilePic: UIImageView! {
    didSet {
      profilePic.makeRounded()
    }
  }

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var aboutLabel: UILabel!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()

  }

}

extension UserProfileView: BindableType {
  func bindViewModel() {
    disposeBag.insert(
      //Information Binding
      viewModel.isVerified.map{ !$0 }.drive(isVerifiedIcon.rx.isHidden),
      viewModel.swapsQty.drive(swapsQtyLabel.rx.text),
      viewModel.reputationNumber.drive(praiseQtyLabel.rx.text),
      viewModel.username.drive(nameLabel.rx.text),
      viewModel.about.drive(aboutLabel.rx.text),
      viewModel.profileImageUrl.drive(onNext: { [unowned self] url in
        self.profilePic.kf.setImage(with: url, options: [.transition(.fade(0.2))])
      })
    )
    
    viewModel.userInterest
    .do(onNext: { [unowned self] interest in
      let list: [TagView] = interest
        .filter { $0.groupingSet == nil }
        .compactMap { interest in
          let view = TagView(title: interest.name.localized)
          view.gradientSelectedColor = true
          view.selectedBackgroundColor = UIColor(hex: "#\(interest.hexColor ?? "#000000")", alpha: 1.0)
          view.selectedTextColor = .white
          view.selectedBorderColor = .clear
          view.borderWidthForTag = 1.0
          view.cornerRadiusForTag = 17.0
          view.paddingX = 15
          view.paddingY = 10
          view.borderColorForTag = UIColor(hex: "#\(interest.hexColor ?? "#000000")", alpha: 0.16)
          view.textColor = .white
          view.textFont = UIFont(name: "Avenir-Heavy", size: 17.0)!
          view.tagBackgroundColor = UIColor(hex: "#\(interest.hexColor ?? "#000000")", alpha: 1.0) ?? .white
          view.tag = interest.id
          return view
      } 

      let sets: [TagView] = interest.removingDuplicates()
        .filter { $0.groupingSet != nil }
        .compactMap { interest in
          let view = TagView(title: interest.groupingSet!.localized)
          view.gradientSelectedColor = true
          view.selectedBackgroundColor = UIColor(hex: "#\(interest.hexColor ?? "#000000")", alpha: 1.0)
          view.selectedTextColor = .white
          view.selectedBorderColor = .clear
          view.borderWidthForTag = 1.0
          view.cornerRadiusForTag = 17.0
          view.paddingX = 15
          view.paddingY = 10
          view.borderColorForTag = UIColor(hex: "#\(interest.hexColor ?? "#000000")", alpha: 0.16)
          view.textColor = .white
          view.textFont = UIFont(name: "Avenir-Heavy", size: 17.0)!
          view.tagBackgroundColor = UIColor(hex: "#\(interest.hexColor ?? "#000000")", alpha: 1.0) ?? .white
          view.isUserInteractionEnabled = false
          return view
      }

      let views = (sets + list)
      self.tagList.addTagViews(views)
    })
      .subscribe(onNext: { _ in
        self.tagList.tagViews.forEach { $0.isSelected = true }
      })
    .disposed(by: disposeBag)
  }
}
