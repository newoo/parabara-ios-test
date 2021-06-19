//
//  ProductsViewReactor.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import ReactorKit

final class ProductsViewReactor: Reactor {
  enum Action {
    case enter
    case loadMore
    case remove(Int)
  }
  
  enum Mutation {
    case setProducts(ProductList)
    case appendProducts(ProductList)
    case removeProduct(UInt)
  }
  
  struct State {
    var products = [Product]()
    var nextPage = 1
    let size = 10
  }
  
  let initialState = State()
  
  let httpClient = HTTPClient<ProductAPI>()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .enter:
      return getProducts(page: 1).map { .setProducts($0) }
      
    case .loadMore:
      return getProducts(page: currentState.nextPage).map { .appendProducts($0) }
      
    case let .remove(index):
      let id = currentState.products[index].id
      return httpClient.rx.request(.delete(id))
        .do(onSuccess: { print($0) })
        .map(BaseResponse<Bool>.self)
        .map { $0.data }
        .asObservable()
        .flatMap { isSuccess in
          isSuccess
            ? Observable.just(Mutation.removeProduct(id))
            : Observable.empty()
        }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    
    switch mutation {
    case let .setProducts(productList):
      state.products = productList.rows
      state.nextPage = productList.page + 1
      
    case let .appendProducts(productList):
      state.products.append(contentsOf: productList.rows)
      state.nextPage = productList.page + 1
      
    case let .removeProduct(id):
      state.products.removeAll { $0.id == id }
    }
    
    return state
  }
  
  private func getProducts(page: Int) -> Observable<ProductList> {
    return httpClient.rx.request(.list(page: page, size: currentState.size))
      .map(BaseResponse<ProductList>.self)
      .map { $0.data }
      .asObservable()
  }
}
