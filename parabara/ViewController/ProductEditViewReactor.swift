//
//  ProductEditViewReactor.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import ReactorKit

final class ProductEditViewReactor: Reactor {
  enum Action {
    case confirm
    case inputTitle(String)
    case inputContent(String)
    case inputPrice(Int)
  }
  
  enum Mutation {
    case setTitle(String)
    case setContent(String)
    case setPrice(Int)
    case isCompleted(Bool)
  }
  
  struct State {
    var title: String?
    var content: String?
    var price: Int?
    var isCompleted = false
  }
  
  let initialState = State()
  
  let httpClient = HTTPClient<ProductAPI>()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .inputTitle(title):
      return .just(.setTitle(title))
      
    case let .inputContent(content):
      return .just(.setContent(content))
      
    case let .inputPrice(price):
      return .just(.setPrice(price))
      
    case .confirm:
      guard let title = currentState.title,
            let content = currentState.content,
            let price = currentState.price else {
        return .empty()
      }
      
      return httpClient.rx.request(.create(title: title, content: content, price: price))
        .map(BaseResponse<Product>.self)
        .asObservable()
        .map { .isCompleted(!$0.error) }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    
    switch mutation {
    case let .setTitle(title):
      state.title = title
      
    case let .setContent(content):
      state.content = content
      
    case let .setPrice(price):
      state.price = price
      
    case let .isCompleted(isCompleted):
      state.isCompleted = isCompleted
    }
    
    return state
  }
}

