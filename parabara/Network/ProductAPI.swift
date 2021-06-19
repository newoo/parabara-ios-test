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
  
  var baseURL: URL {
    return URL(string: "https://api.recruit-test.parabara.kr")!
  }
  
  var route: Route {
    switch self {
    case .list:
      return .get("/api/product")
    }
  }
  
  var parameters: Parameters? {
    nil
  }
  
  var headers: [String: String]? {
    return [
      "Accept": "application/json",
      "x-token": "TOKEN"
    ]
  }
  
  var sampleData: Data {
    Data()
  }
}
