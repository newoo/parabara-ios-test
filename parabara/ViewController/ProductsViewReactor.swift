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
    case remove(Int)
  }
  
  enum Mutation {
    case setProducts([Product])
    case removeProduct(UInt)
  }
  
  struct State {
    var products = [Product]()
  }
  
  let initialState = State()
  
  let httpClient = HTTPClient<ProductAPI>()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .enter:
      return httpClient.rx.request(.list)
        .map(BaseResponse<ProductList>.self)
        .map { $0.data.rows }
        .asObservable()
        .map { .setProducts($0) }
      
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
    case let .setProducts(products):
      state.products = products
      
    case let .removeProduct(id):
      state.products.removeAll { $0.id == id }
    }
    
    return state
  }
}
