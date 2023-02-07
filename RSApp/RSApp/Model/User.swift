//
//  User.swift
//  RSApp
//
//  Created by Augustin Diabira on 21/12/2022.
//


import SwiftUI
import FirebaseFirestoreSwift


struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username:String
    var userbio:String
    var userProfileURL:URL
    var userEmail:String
    var userUID: String
    
    enum CodingKeys: CodingKey {
    case id
    case username
    case userbio
    case userProfileURL
    case userEmail
    case userUID
    }
}
