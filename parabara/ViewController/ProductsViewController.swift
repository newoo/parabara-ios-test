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
    reactor?.action.onNext(.enter)
  }
  
  private func setConstraints() {
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
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
  }
}

