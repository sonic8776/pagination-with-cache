//
//  JsonEncoder+codableModelToJson.swift
//  Houzz-Pagination
//
//  Created by Judy Tsai on 2024/7/14.
//

import Foundation

extension JSONEncoder {
    func toJson<T: Codable>(from object: T) -> [String: Any]? {
        do {
            let data = try encode(object)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? [String: Any]
        } catch {
            return nil
        }
    }
}
