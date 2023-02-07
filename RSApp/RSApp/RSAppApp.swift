//
//  RSAppApp.swift
//  RSApp
//
//  Created by Augustin Diabira on 18/12/2022.
//

import SwiftUI
import Firebase

@main
struct RSAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
