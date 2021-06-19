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
    case selectImages(Set<Int>)
  }
  
  enum Mutation {
    case setTitle(String)
    case setContent(String)
    case setPrice(Int)
    case setImages(Set<Int>)
    case isCompleted(Bool)
  }
  
  struct State {
    var product: Product?
    var title: String?
    var content: String?
    var price: Int?
    var isCompleted = false
    var selectedImages = Set<Int>()
  }
  
  let initialState: State
  
  let httpClient = HTTPClient<ProductAPI>()
  
  init(product: Product? = nil) {
    if let product = product {
      initialState = State(product: product,
                           title: product.title,
                           content: product.content,
                           price: Int(product.price))
      return
    }
    
    initialState = State()
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .inputTitle(title):
      return .just(.setTitle(title))
      
    case let .inputContent(content):
      return .just(.setContent(content))
      
    case let .inputPrice(price):
      return .just(.setPrice(price))
      
    case let .selectImages(indices):
      return .just(.setImages(indices))
      
    case .confirm:
      guard let title = currentState.title,
            let content = currentState.content,
            let price = currentState.price else {
        return .empty()
      }
      
      if let product = currentState.product {
        return httpClient.rx.request(.update(id: product.id,
                                      title: title,
                                      content: content,
                                      price: Int(price)))
          .map(BaseResponse<Product>.self)
          .asObservable()
          .map { .isCompleted(!$0.error) }
      }
      
      let observables = currentState.selectedImages
        .compactMap { UIImage(named: "sample-image-\($0 + 1)") }
        .map {
          httpClient.rx.request(.upload(image: $0))
            .map(BaseResponse<UploadedImage>.self)
            .map { $0.data.id }
            .asObservable()
        }
      
      return Observable.combineLatest(observables).flatMap { [weak self] images in
        self?.httpClient.rx.request(.create(title: title,
                                            content: content,
                                            price: price,
                                            images: images))
          .asObservable() ?? .empty()
      }.map(BaseResponse<Product>.self)
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
      
    case let .setImages(indices):
      state.selectedImages = indices
      
    case let .isCompleted(isCompleted):
      state.isCompleted = isCompleted
    }
    
    return state
  }
}

