//
//  TagsResponse.swift
//  
//
//  Created by Marino Felipe on 10.01.21.
//

struct TagsResponse: Decodable, Equatable {
    struct Tag: Decodable, Equatable {
        let name: String
    }

    let tags: [Tag]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        tags = try container.decode([Tag].self)
    }
}
