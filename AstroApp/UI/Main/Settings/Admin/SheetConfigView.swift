//
//  SheetConfigView.swift
//  AstroApp
//
//  Created by Tristan Chay on 30/7/23.
//

import SwiftUI

struct SheetConfigView: View {
    @ObservedObject var userModel: UserAuthModel = .shared
    @ObservedObject var atManager: AttendanceManager = .shared

    @AppStorage("spreadsheetInput") var spreadsheetInput: String = ""
    @AppStorage("pageTitle") var pageTitle: String = ""

    @AppStorage("headerRow") var headerRow: Int = 0 // default to row #1
    @AppStorage("emailColumn") var emailColumn: Int = 0 // default to column A
    @AppStorage("attendanceStartColumn") var attendanceStartColumn: Int = 1 // default to column B

    @State var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Spreadsheet") {
                    TextField("Spreadsheet URL or ID", text: $spreadsheetInput)
                        .safeAreaInset(edge: .trailing) {
                            if isLoading {
                                ProgressView().progressViewStyle(.circular)
                                    .frame(width: 20, height: 20)
                            } else {
                                Button {
                                    let spreadsheetId = getSpreadsheetIdfromInput(spreadsheetInput)
                                    print("Testing: \(spreadsheetId)")
                                    isLoading = true
                                    Task {
                                        try? await atManager.fetchContentsOfSheet(id: spreadsheetId)
                                        isLoading = false
                                    }
                                } label: {
                                    Image(systemName: "arrow.right.circle")
                                }
                                .disabled(spreadsheetInput.isEmpty)
                                .keyboardShortcut(.return, modifiers: [])
                            }
                        }
                }
                
                if let sheets = atManager.sheets {
                    Section {
                        Picker("Sheet Page", selection: $pageTitle) {
                            Text("Not Selected")
                                .italic()
                                .tag("")
                            ForEach(sheets, id: \.properties.sheetId) { sheet in
                                Text(sheet.properties.title)
                                    .tag(sheet.properties.title)
                            }
                        }
                        
                        if sheets.contains(where: { $0.properties.title == pageTitle }) {
                            Picker("Header Row", selection: $headerRow) {
                                ForEach(1..<11) { index in
                                    Text("\(index)")
                                        .tag(index-1)
                                }
                            }
                            Picker("Email Column", selection: $emailColumn) {
                                ForEach(UnicodeScalar("A").value...UnicodeScalar("K").value, id: \.self) { charCode in
                                    Text(String(UnicodeScalar(charCode)!))
                                        .tag(Int(UnicodeScalar(charCode)!.value - UnicodeScalar("A").value))
                                }
                            }
                            Picker("First Attendance Column", selection: $attendanceStartColumn) {
                                ForEach(UnicodeScalar("A").value...UnicodeScalar("K").value, id: \.self) { charCode in
                                    Text(String(UnicodeScalar(charCode)!))
                                        .tag(Int(UnicodeScalar(charCode)!.value - UnicodeScalar("A").value))
                                }
                            }
                        }
                    } header: {
                        Text("Page")
                    } footer: {
                        NavigationLink {
                            List {
                                ForEach(Array(atManager.loadEmailsFrom(targetSheetName: pageTitle, headerRow: headerRow, emailColumn: emailColumn).keys),
                                        id: \.self) { email in
                                    Text(email)
                                }
                            }
                            .navigationTitle("Preview Emails")
                            .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack {
                                Text("Preview Emails")
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                if spreadsheetInput != "" &&
                    pageTitle != ""    &&
                    (atManager.sheets?.contains(where: { $0.properties.title == pageTitle }) ?? false) {
                    Section {
                        Button("Continue") {
                            atManager.confirmSheet(
                                sheetId: getSpreadsheetIdfromInput(spreadsheetInput),
                                targetSheetName: pageTitle,
                                headerRow: headerRow,
                                emailColumn: emailColumn,
                                attendanceStartColumn: attendanceStartColumn
                            )
                        }
                        .keyboardShortcut(.return, modifiers: .command)
                    }
                }
            }
            .navigationTitle("Spreadsheet Configuration")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func getSpreadsheetIdfromInput(_ input: String) -> String {
        if !input.contains("https://") {
            return input // returns ID (assumption) since it's not URL
        } else {
            return String(input.split(separator: "/")[4]) // returns ID in URL
        }
    }
}

struct SheetConfigView_Previews: PreviewProvider {
    static var previews: some View {
        SheetConfigView()
    }
}
