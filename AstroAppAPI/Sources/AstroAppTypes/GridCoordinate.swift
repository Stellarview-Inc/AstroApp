//
//  GridCoordinate.swift
//
//
//  Created by Tristan Chay on 30/7/23.
//

import Foundation

public struct GridCoordinate: Codable {
    public var sheetId: Int
    public var rowIndex: Int
    public var columnIndex: Int

    public init(sheetId: Int, rowIndex: Int, columnIndex: Int) {
        self.sheetId = sheetId
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
    }
}
