//
//  TagsResponse.swift
//  
//
//  Created by Marino Felipe on 10.01.21.
//

struct TagsResponse: Equatable {
    struct Tag: Decodable, Equatable {
        let name: String
    }

    let tags: [Tag]
}

extension TagsResponse: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        tags = try container.decode([Tag].self)
    }
}
