//
//  ProductsViewController.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/16.
//

import UIKit
import SnapKit
import ReactorKit

class ProductsViewController: UIViewController, View {
  typealias Reactor = ProductsViewReactor
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.rowHeight = 132
    tableView.register(ProductTableViewCell.self,
                       forCellReuseIdentifier: ProductTableViewCell.identifier)
    
    return tableView
  }()
  
  private let addButton: UIButton = {
    let button = UIButton()
    button.setTitle("ADD", for: .normal)
    button.backgroundColor = .blue
    
    return button
  }()
  
  var disposeBag = DisposeBag()
  
  init(reactor: ProductsViewReactor = .init()) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }
  
  required init?(coder: NSCoder) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = ProductsViewReactor()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setConstraints()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reactor?.action.onNext(.enter)
  }
  
  private func setConstraints() {
    view.addSubview(tableView)
    view.addSubview(addButton)
    
    tableView.snp.makeConstraints {
      $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
    }
    
    addButton.snp.makeConstraints {
      $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
      $0.top.equalTo(tableView.snp.bottom)
      $0.height.equalTo(80)
    }
  }
  
  func bind(reactor: ProductsViewReactor) {
    reactor.state.map { $0.products }
      .bind(to: tableView.rx.items(
        cellIdentifier: ProductTableViewCell.identifier,
        cellType: ProductTableViewCell.self
      )) { _, item, cell in
        cell.productInput.accept(item)
      }.disposed(by: disposeBag)
    
    tableView.rx.itemDeleted
      .map { Reactor.Action.remove($0.row) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    addButton.rx.tap
      .subscribe(onNext: { [weak self] in
        let viewController = ProductEditViewController()
        viewController.modalPresentationStyle = .fullScreen
        self?.present(viewController, animated: true, completion: nil)
      }).disposed(by: disposeBag)
  }
}

