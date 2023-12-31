//
//  UserAuthModel.swift
//  AstroApp
//
//  Created by Tristan Chay on 30/7/23.
//

import SwiftUI
import GoogleSignIn
import AstroAppAPI

class UserAuthModel: ObservableObject {
    static let shared: UserAuthModel = .init()

    @Published var isLoggedIn: Bool?
    @Published var grantedScopes: [String] = []

    @Published var givenName: String?
    @Published var familyName: String?
    @Published var fullName: String?
    @Published var email: String?
    @Published var profilePicUrl: String?
    @Published var errorMessage: String?
    @Published var token: String? {
        didSet {
            APISecretManager.accessToken = token ?? ""
        }
    }

    let neededScopes: [String] = [
        "https://www.googleapis.com/auth/spreadsheets"
    ]

    private init() {
        let clientID = "495723642922-lt7jr3c48t8oopjj2fpqrc832107r1n3.apps.googleusercontent.com"
        let signInConfig = GIDConfiguration(clientID: clientID)

        // load the email
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            self.email = email
        }

        GIDSignIn.sharedInstance.configuration = signInConfig
        restoreSignIn()
    }

    func checkStatus() {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            self.givenName = nil
            self.familyName = nil
            self.fullName = nil
            self.email = nil
            self.profilePicUrl = nil
            self.isLoggedIn = false
            self.token = nil
            return
        }

        let givenName = user.profile?.givenName
        let familyName = user.profile?.familyName
        let fullName = user.profile?.name
        let email = user.profile?.email
        let profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
        self.givenName = givenName
        self.familyName = familyName
        self.fullName = fullName
        self.email = email
        self.profilePicUrl = profilePicUrl
        self.isLoggedIn = true
        self.token = user.accessToken.tokenString
        checkPermissions()

        // save the email
        if let email {
            UserDefaults.standard.set(email, forKey: "userEmail")
        }
    }

    private func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.errorMessage = "error: \(error.localizedDescription)"
            }

            self.checkStatus()
        }
    }

    func signIn() {
        guard let presentingController = getPresenter() else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingController) { _, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }

            self.checkStatus()
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        UserDefaults.standard.removeObject(forKey: "userEmail")
        self.checkStatus()
    }

    @discardableResult
    func checkPermissions(requestIfMissing: Bool = true) -> Bool {
        guard let user = GIDSignIn.sharedInstance.currentUser else { return false }
        let grantedScopes = user.grantedScopes
        self.grantedScopes = user.grantedScopes ?? []

        if grantedScopes == nil || !hasNeededScopes() {
            // Request additional scopes.
            if requestIfMissing {
                requestPermissions()
            }
            return false
        }
        return true
    }

    func hasNeededScopes() -> Bool {
        for scope in neededScopes {
            if !grantedScopes.contains(scope) {
                return false
            }
        }
        return true
    }

    func requestPermissions() {
        guard let user = GIDSignIn.sharedInstance.currentUser,
              let presentingController = getPresenter() else {
            print("Could not get user")
            return
        }

        // get the scopes that we don't have
        var requestingScopes: [String] = []
        requestingScopes = neededScopes.filter({ !grantedScopes.contains($0) })

        user.addScopes(requestingScopes, presenting: presentingController) { signInResult, error in
            guard error == nil else { return }
            self.checkPermissions(requestIfMissing: false)
            guard let newUser = signInResult?.user else { return }
            let accessToken = newUser.accessToken.tokenString
            self.token = accessToken
        }
    }

#if os(iOS)
    typealias PresentingController = UIViewController
#else
    typealias PresentingController = NSWindow
#endif

    func getPresenter() -> PresentingController? {
#if os(iOS)
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window,
              let presentingController = window?.rootViewController else {
            print("Could not get presenting uiviewcontroller")
            return nil
        }
#else
        guard let presentingController = NSApp.windows.first else {
            print("Could not get presenting nswindow")
            return nil
        }
#endif
        return presentingController
    }
}
