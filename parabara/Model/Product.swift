//
//  Product.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import Foundation

struct Product: Decodable {
  let id: UInt
  let title: String
  let content: String
  let price: UInt
  let images: [String]
  
  enum CodingKeys: String, CodingKey {
    case id, title, content, price, images
  }
}
