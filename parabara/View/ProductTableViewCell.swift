//
//  ProductTableViewCell.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import UIKit
import RxSwift
import RxCocoa

class ProductTableViewCell: UITableViewCell {
  static let identifier = "ProductTableViewCell"
  
  let thumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .gray
    
    return imageView
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 18)
    
    return label
  }()
  
  let contentLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 12)
    label.textColor = .darkGray
    label.numberOfLines = 2
    
    return label
  }()
  
  let priceLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .red
    
    return label
  }()
  
  let productInput = PublishRelay<Product>()
  
  private var disposeBag = DisposeBag()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    thumbnailImageView.image = nil
  }
  
  private func setConstraints() {
    addSubviews()
    
    thumbnailImageView.snp.makeConstraints {
      $0.leading.top.bottom.equalToSuperview().inset(16)
      $0.width.height.equalTo(100)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
      $0.top.equalTo(thumbnailImageView.snp.top).offset(8)
    }
    
    contentLabel.snp.makeConstraints {
      $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
      $0.top.equalTo(titleLabel.snp.bottom).offset(4)
    }
    
    priceLabel.snp.makeConstraints {
      $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
      $0.bottom.equalTo(thumbnailImageView.snp.bottom).offset(-4)
    }
  }
  
  private func addSubviews() {
    contentView.addSubview(thumbnailImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(contentLabel)
    contentView.addSubview(priceLabel)
  }
  
  private func bind() {
    productInput.compactMap { $0.images.first }
      .observeOn(MainScheduler.instance)
      .bind(to: thumbnailImageView.rx.imageURL)
      .disposed(by: disposeBag)
    
    productInput.compactMap { $0.title }
      .observeOn(MainScheduler.instance)
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
    
    productInput.compactMap { $0.content }
      .observeOn(MainScheduler.instance)
      .bind(to: contentLabel.rx.text)
      .disposed(by: disposeBag)
    
    productInput.compactMap { String($0.price) + "원" }
      .observeOn(MainScheduler.instance)
      .bind(to: priceLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
