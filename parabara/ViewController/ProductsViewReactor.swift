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
  }
  
  enum Mutation {
    case setProducts([Product])
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
        .map(BaseResponse.self)
        .map { $0.data.rows }
        .asObservable()
        .map { .setProducts($0) }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    
    switch mutation {
    case let .setProducts(products):
      state.products = products
    }
    
    return state
  }
}
