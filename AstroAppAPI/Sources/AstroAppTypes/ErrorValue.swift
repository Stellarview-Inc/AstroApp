//
//  ErrorValue.swift
//
//
//  Created by Tristan Chay on 30/7/23.
//

import Foundation

public struct ErrorValue: Codable {
    public var type: ErrorType
    public var message: String
}
