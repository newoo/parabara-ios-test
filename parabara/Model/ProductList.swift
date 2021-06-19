//
//  ProductList.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import Foundation

struct ProductList: Decodable {
  let page: Int
  let total: Int
  let records: Int
  let rows: [Product]
  
  enum CodingKeys: String, CodingKey {
    case page, total, records, rows
  }
}
