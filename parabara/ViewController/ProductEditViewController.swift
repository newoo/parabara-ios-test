//
//  ProductEditViewController.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import UIKit
import SnapKit
import ReactorKit
import RxGesture

class ProductEditViewController: UIViewController, ReactorKit.View {
  typealias Reactor = ProductEditViewReactor
  
  private let closeButton: UIButton = {
    let button = UIButton()
    button.setTitle("Close", for: .normal)
    button.setTitleColor(.blue, for: .normal)
    
    return button
  }()
  
  private let confirmButton: UIButton = {
    let button = UIButton()
    button.setTitle("Confirm", for: .normal)
    button.setTitleColor(.blue, for: .normal)
    
    return button
  }()
  
  private let titleTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Title"
    
    return textField
  }()
  
  private let contentTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Content"
    textField.keyboardType = .asciiCapableNumberPad
    
    return textField
  }()
  
  private let priceTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Price"
    
    return textField
  }()
  
  private let sampleImageViews = (1...3).map {
    UIImage(named: "sample-image-\($0)")
  }.map { UIImageView(image: $0) }
  
  private let textFieldStackView: UIStackView
  private let imageStackView: UIStackView
  
  private var selectedIndices = Set<Int>()
  
  var disposeBag = DisposeBag()
  
  init(reactor: ProductEditViewReactor = .init()) {
    textFieldStackView = UIStackView(arrangedSubviews: [titleTextField,
                                               contentTextField,
                                               priceTextField])
    imageStackView = UIStackView(arrangedSubviews: sampleImageViews)
    
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setConstraints()
  }
  
  private func setConstraints() {
    view.addSubview(closeButton)
    view.addSubview(confirmButton)
    view.addSubview(textFieldStackView)
    view.addSubview(imageStackView)
    
    textFieldStackView.axis = .vertical
    textFieldStackView.spacing = 4
    
    imageStackView.axis = .horizontal
    imageStackView.spacing = 8
    imageStackView.distribution = .fillEqually
    
    closeButton.snp.makeConstraints {
      $0.leading.top.equalTo(view.safeAreaLayoutGuide).inset(16)
    }
    
    confirmButton.snp.makeConstraints {
      $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
    }
    
    textFieldStackView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(72)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.8)
    }
    
    imageStackView.snp.makeConstraints {
      $0.top.equalTo(textFieldStackView.snp.bottom).offset(16)
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(120)
    }
  }
  
  func bind(reactor: ProductEditViewReactor) {
    reactor.state.compactMap { $0.product }
      .take(1)
      .do(onNext: { [weak self] _ in
        self?.imageStackView.isHidden = true
      }).subscribe(onNext: { [weak self] product in
        self?.titleTextField.text = product.title
        self?.contentTextField.text = product.content
        self?.priceTextField.text = String(product.price)
      }).disposed(by: disposeBag)
    
    reactor.state.map { $0.isCompleted }
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      }).disposed(by: disposeBag)
    
    closeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).disposed(by: disposeBag)
    
    confirmButton.rx.tap
      .map { Reactor.Action.confirm }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    titleTextField.rx.text
      .orEmpty
      .map { Reactor.Action.inputTitle($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    contentTextField.rx.text
      .orEmpty
      .map { Reactor.Action.inputContent($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    priceTextField.rx.text
      .orEmpty
      .compactMap { Int($0) }
      .map { Reactor.Action.inputPrice($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    sampleImageViews.enumerated().forEach { [weak self] offset, imageView in
      guard let self = self else {
        return
      }
      
      imageView.rx.tapGesture()
        .when(.recognized)
        .subscribe(onNext: { [weak self] _ in
          if self?.selectedIndices.contains(offset) == true {
            self?.selectedIndices.remove(offset)
            imageView.layer.borderWidth = 0
            self?.reactor?.action.onNext(.selectImages(self?.selectedIndices ?? []))
            return
          }
          
          self?.selectedIndices.insert(offset)
          imageView.layer.borderWidth = 4
          imageView.layer.borderColor = UIColor.red.cgColor
          self?.reactor?.action.onNext(.selectImages(self?.selectedIndices ?? []))
        }).disposed(by: self.disposeBag)
    }
  }
}
