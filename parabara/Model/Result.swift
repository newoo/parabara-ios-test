//
//  Result.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import Foundation

struct Result: Decodable {
  let page: UInt
  let total: UInt
  let records: UInt
  let rows: [Product]
  
  enum CodingKeys: String, CodingKey {
    case page, total, records, rows
  }
}
