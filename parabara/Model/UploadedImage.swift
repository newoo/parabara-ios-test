//
//  UploadedImage.swift
//  parabara
//
//  Created by Taeheon Woo on 2021/06/20.
//

import Foundation

struct UploadedImage: Decodable {
  let id: Int
  let url: String
  
  enum Codingkeys: String, CodingKey { 
    case id, url
  }
}
