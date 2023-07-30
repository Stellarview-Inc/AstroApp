//
//  ContentView.swift
//  AstroApp
//
//  Created by Tristan Chay on 30/7/23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var userModel: UserAuthModel = .shared
    @ObservedObject var atManager: AttendanceManager = .shared

    var body: some View {
        if let isLoggedIn = userModel.isLoggedIn {
            if isLoggedIn && userModel.hasNeededScopes() {
                HomeView()
            } else {
                SignInView()
            }
        } else {
            ProgressView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
