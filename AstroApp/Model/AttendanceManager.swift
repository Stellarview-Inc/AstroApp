//
//  AttendanceManager.swift
//  AstroApp
//
//  Created by Tristan Chay on 30/7/23.
//

import Foundation
import AstroAppAPI
import AstroAppTypes

class AttendanceManager: ObservableObject {
    static let shared: AttendanceManager = .init()

    // MARK: Sheet API stuff
    @Published internal var sheet: Spreadsheet?

    internal var sheetId: String?
    internal var targetSheetName: String?
    internal var headerRow: Int?
    internal var emailColumn: Int?
    internal var attendanceStartColumn: Int?

    public var sheets: [Sheet]? { sheet?.sheets }
    public var sheetSetUp: Bool {
        sheetId != nil &&
        sheets != nil &&
        targetSheetName != nil &&
        headerRow != nil &&
        emailColumn != nil &&
        attendanceStartColumn != nil
    }

    func fetchContentsOfSheet(id: String) async throws {
        try await withCheckedThrowingContinuation { cont in
            AstroAppAPI.AASpreadsheets.get(
                params: .init(spreadsheetId: id),
                query: .init(includeGridData: true),
                data: .init()
            ) { result in
                switch result {
                case .success(let sheet):
                    DispatchQueue.main.async {
                        self.sheet = sheet
                    }
                    cont.resume(returning: Void())
                case .failure(let error):
                    print("Error :(")
                    cont.resume(throwing: error)
                }
            }
        }
    }

    func confirmSheet(
        sheetId: String,
        targetSheetName: String,
        headerRow: Int,
        emailColumn: Int,
        attendanceStartColumn: Int
    ) {
        self.sheetId = sheetId
        self.targetSheetName = targetSheetName
        self.headerRow = headerRow
        self.emailColumn = emailColumn
        self.attendanceStartColumn = attendanceStartColumn

        loadEmails()
        loadHeaders()
    }

    internal var emailsRowMap: [String: Int] = [:]
    internal var attendanceDateColumnMap: [String: Int] = [:]
    internal var todayColumn: Int?

    // MARK: For use marking attendance
    func verifyExistance(email: String) -> Bool {
        emailsRowMap.keys.contains(email)
    }

    func submitAttendance(details: AttendanceInstance) async throws {
        print("Marking \(details.email) as present at \(details.entryTime.description)")

        guard let sheetId, let todayColumn,
              let emailRow = emailsRowMap[details.email],
              let sheets = sheet?.sheets,
              let numericalSheetId = sheets.first(where: { $0.properties.title == targetSheetName })?.properties.sheetId
        else {
            print("Could not find column or email row")
            return
        }
        let markedTime = details.entryTime.formatted(date: .omitted, time: .standard)

        // TODO: Write to it at that row/column
        let updateCellsRequest = UpdateCellsRequest(
            rows: [.init(values: [.init(userEnteredValue: .init(stringValue: "1"))])], // change to markedtime for current time
            fields: "*",
            start: .init(sheetId: numericalSheetId, rowIndex: emailRow, columnIndex: todayColumn)
        )

        try await withCheckedThrowingContinuation { continuation in
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
                    continuation.resume(returning: Void())
                case .failure(_):
                    print("Failure :(")
                    continuation.resume(throwing: AttendanceError.couldNotSubmit)
                }
            }
        }
    }

    enum AttendanceError: Error, CaseIterable, Equatable, Hashable {
        case notInAttendanceList
        case couldNotSubmit
    }
}
