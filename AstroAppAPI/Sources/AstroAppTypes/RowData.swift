//
//  RowData.swift
//
//
//  Created by Tristan Chay on 30/7/23.
//

import Foundation

public struct RowData: Codable {
    public var values: [CellData]

    public init(values: [CellData]) {
        self.values = values
    }
}
