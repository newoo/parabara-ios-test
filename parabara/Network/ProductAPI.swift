//
//  ProductAPI.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import Moya
import MoyaSugar

enum ProductAPI: SugarTargetType {
  case list(page: Int, size: Int)
  case upload(image: UIImage)
  case create(title: String, content: String, price: Int, images: [Int])
  case update(id: UInt, title: String, content: String, price: Int)
  case delete(UInt)
  
  var baseURL: URL {
    return URL(string: "https://api.recruit-test.parabara.kr/api/product")!
  }
  
  var route: Route {
    switch self {
    case .list:
      return .get("")
      
    case .upload:
      return .post("/upload")
      
    case .create:
      return .post("")
      
    case .update:
      return .put("")
      
    case let .delete(id):
      return .delete("/\(id)")
    }
  }
  
  var parameters: Parameters? {
    switch self {
    case let .list(page, size):
      return [
        "page": page,
        "size": size
      ]
    
    case let .create(title, content, price, images):
      return [
        "title": title,
        "content": content,
        "price": price,
        "images": images.compactMap { String($0) }.joined(separator:", ")
      ]
      
    case let .update(id, title, content, price):
      return [
        "id": id,
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
      "Accept": "application/json",
      "x-token": "YOUR-KEY"
    ]
  }
  
  var task: Task {
    switch self {
    case let .upload(image):
      return Task.uploadMultipart(multipartData(image: image))
      
    case .list, .create, .update:
      guard let parameters = self.parameters else {
        return .requestPlain
      }
      
      return .requestParameters(parameters: parameters.values, encoding: parameters.encoding)
      
    default:
      return .requestPlain
    }
  }
  
  var sampleData: Data {
    Data()
  }
  
  private func multipartData(image: UIImage) -> [MultipartFormData] {
    guard let data = image.jpegData(compressionQuality: 0.6) else {
      return [MultipartFormData]()
    }
    
    return [MultipartFormData(provider: .data(data),
                              name: "image",
                              fileName: "image.jpeg",
                              mimeType:"image/jpeg")]
  }
}
