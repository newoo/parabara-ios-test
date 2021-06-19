//
//  BaseResponse.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/19.
//

import Foundation

struct BaseResponse: Decodable {
  let code: String
  let status: UInt
  let data: Result
  let error: Bool
  let message: String
  
  enum CodingKeys: String, CodingKey {
    case code, status, data, error, message
  }
}
