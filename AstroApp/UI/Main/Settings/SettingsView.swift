//
//  SettingsView.swift
//  AstroApp
//
//  Created by Tristan Chay on 30/7/23.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var userModel: UserAuthModel = .shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    navigationLabelItem(labelText: "General",
                                        labelImageName: "gear",
                                        labelImageColor: .gray)
                } header: {
                    Text("Settings")
                }
                
                Section {
                    NavigationLink {
                        SheetConfigView()
                    } label: {
                        navigationLabelItem(labelText: "Spreadsheet",
                                            labelImageName: "tablecells",
                                            labelImageColor: .green)
                    }
                } header: {
                    Text("Administrative")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        userModel.signOut()
                    } label: {
                        Text("Sign out")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    
    func navigationLabelItem(labelText: String, labelImageName: String, labelImageColor: Color) -> some View {
        HStack {
            Image(systemName: labelImageName)
                .resizable()
                .scaledToFit()
                .fontWeight(.bold)
                .padding(5)
                .frame(width: 30, height: 30)
                .background(labelImageColor)
                .foregroundColor(.white)
                .cornerRadius(6)
                .padding(.trailing, 5)
            
            Text(labelText)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
