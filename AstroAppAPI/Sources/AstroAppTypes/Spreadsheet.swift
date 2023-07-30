//
//  Spreadsheet.swift
//
//
//  Created by Tristan Chay on 30/7/23.
//

import Foundation

public struct Spreadsheet: Codable {
    public var spreadsheetId: String
    public var sheets: [Sheet]
}
