//
//  ProductAPI.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import Moya
import MoyaSugar

enum ProductAPI: SugarTargetType {
  case list
  case create(title: String, content: String, price: Int)
  case delete(UInt)
  
  var baseURL: URL {
    return URL(string: "https://api.recruit-test.parabara.kr/api/product")!
  }
  
  var route: Route {
    switch self {
    case .list:
      return .get("")
      
    case .create:
      return .post("")
      
    case let .delete(id):
      return .delete("/\(id)")
    }
  }
  
  var parameters: Parameters? {
    switch self {
    case let .create(title, content, price):
      return [
        "title": title,
        "content": content,
        "price": price
      ]
      
    default:
      return nil
    }
  }
  
  var headers: [String: String]? {
    return [
      "Accept": "application/json"
    ]
  }
  
  var sampleData: Data {
    Data()
  }
}
