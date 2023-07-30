//
//  AttendanceManager+Load.swift
//  AstroApp
//
//  Created by Tristan Chay on 30/7/23.
//

import Foundation
import AstroAppAPI
import AstroAppTypes

extension AttendanceManager {
    internal func loadEmails() {
        guard let targetSheetName, let headerRow, let emailColumn else {
            print("Target sheet does not exist")
            return
        }

        let emails = loadEmailsFrom(targetSheetName: targetSheetName, headerRow: headerRow, emailColumn: emailColumn)

        DispatchQueue.main.async {
            self.emailsRowMap = emails
            self.objectWillChange.send()
        }
    }

    func loadEmailsFrom(targetSheetName: String, headerRow: Int, emailColumn: Int) -> [String: Int] {
        guard let targetSheet = sheet?.sheets.first(where: { $0.properties.title == targetSheetName }),
              let sheetData = targetSheet.data.first
        else {
            print("Target sheet does not exist")
            return [:]
        }

        let headerRowOffset = (sheetData.startRow ?? 0) + 1
        let emailColumnOffset = (sheetData.startColumn ?? 0)

        var emails: [String: Int] = [:]

        for (relativeIndex, row) in sheetData.rowData[(headerRow+headerRowOffset)...].enumerated() {
            if row.values.count > emailColumn + emailColumnOffset,
               let value = row.values[emailColumn + emailColumnOffset].formattedValue {
                emails[value] = emailColumn + emailColumnOffset + relativeIndex
            }
        }

        return emails
    }

    internal func loadHeaders() {
        guard let targetSheetName, let headerRow, let attendanceStartColumn,
              let targetSheet = sheet?.sheets.first(where: { $0.properties.title == targetSheetName }),
              let sheetData = targetSheet.data.first
        else {
            print("Target sheet does not exist")
            return
        }

        let headerData = sheetData.rowData[headerRow + (sheetData.startRow ?? 0)]
        let startPoint = attendanceStartColumn + (sheetData.startColumn ?? 0)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"

        // capture all date headers that match the format dd/MM/yy
        var headers: [String: Int] = [:]

        for (relativeIndex, cell) in headerData.values[startPoint...].enumerated() {
            guard let value = cell.formattedValue,
                  let asDate = dateFormatter.date(from: value)
            else { continue }
            let fixedString = dateFormatter.string(from: asDate)
            headers[fixedString] = (sheetData.startColumn ?? 0) + attendanceStartColumn + relativeIndex
        }

        print("Headers: \(headers)")

        let today = dateFormatter.string(from: .now)
        print("Today: \(today)")

        DispatchQueue.main.async {
            self.attendanceDateColumnMap = headers
            if let todayColumn = headers[today] {
                print("Already indexed at column \(todayColumn)")
                self.todayColumn = todayColumn
            } else { // if its not indexed, create a new column for it
                let backupValue = (sheetData.startColumn ?? 0) + attendanceStartColumn
                let newColumn = (headers.values.max() ?? backupValue) + 1
                self.todayColumn = newColumn

                self.createHeaderFor(date: today, at: newColumn)
            }
        }
    }

    private func createHeaderFor(date: String, at column: Int) {
        guard let sheetId, let headerRow,
              let sheets = sheet?.sheets,
              let numericalSheetId = sheets.first(where: { $0.properties.title == targetSheetName })?.properties.sheetId
        else {
            print("No header row found")
            return
        }

        // TODO: Write to it at that row/column
        let updateCellsRequest = UpdateCellsRequest(
            rows: [.init(values: [.init(userEnteredValue: .init(stringValue: date))])],
            fields: "*",
            start: .init(sheetId: numericalSheetId, rowIndex: headerRow, columnIndex: column)
        )

        AstroAppAPI.AASpreadsheets.update(
            params: .init(spreadsheetId: sheetId),
            query: .init(),
            data: .init(
                requests: [
                    .init(updateCells: updateCellsRequest)
                ],
                includeSpreadsheetInResponse: false,
                responseRanges: [],
                responseIncludeGridData: false)
        ) { result in
            switch result {
            case .success(_):
                print("Success!")
            case .failure(_):
                print("Failure :(")
            }
        }
    }
}

