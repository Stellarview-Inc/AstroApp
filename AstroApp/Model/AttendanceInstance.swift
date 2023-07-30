//
//  AttendanceInstance.swift
//  AstroApp
//
//  Created by Tristan Chay on 30/7/23.
//

import Foundation

struct AttendanceInstance {
    var email: String
    var entryTime: Date

    init(email: String, entryTime: Date) {
        self.email = email
        self.entryTime = entryTime
    }
}
