//
//  UpdateRequest.swift
//
//
//  Created by Tristan Chay on 30/7/23.
//

import Foundation
import AstroAppTypes

public struct UpdateRequest: Codable {
    // theres far more types than this, but we don't need them
    var updateCells: UpdateCellsRequest

    public init(updateCells: UpdateCellsRequest) {
        self.updateCells = updateCells
    }
}

public struct UpdateCellsRequest: Codable {
    var rows: [RowData]
    var fields: String = "*"
    var start: GridCoordinate
    var range: GridRange?

    public init(rows: [RowData],
                fields: String,
                start: GridCoordinate,
                range: GridRange? = nil) {
        self.rows = rows
        self.fields = fields
        self.start = start
        self.range = range
    }
}
