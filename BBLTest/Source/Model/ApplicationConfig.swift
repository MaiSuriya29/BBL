//
//  ApplicationConfig.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import Foundation
struct ApplicationConfig: Decodable {

    let issuer: String
    let clientID: String
    let redirectUri: String
    let postLogoutRedirectUri: String
    let scope: String
    let grantType : String
    let clientSecret : String
    
    init() {
        self.issuer = ""
        self.clientID = ""
        self.redirectUri = ""
        self.postLogoutRedirectUri = ""
        self.scope = ""
        self.grantType = ""
        self.clientSecret = ""
    }
    
    func getIssuerUri() -> (URL?, Error?) {
        
        guard let url = URL(string: self.issuer) else {

            let error = ApplicationError(title: "Invalid Configuration Error", description: "The issuer URI could not be parsed")
            return (nil, error)
        }
        
        return (url, nil)
    }

    func getRedirectUri() -> (URL?, Error?) {
        
        guard let url = URL(string: self.redirectUri) else {

            let error = ApplicationError(title: "Invalid Configuration Error", description: "The redirect URI could not be parsed")
            return (nil, error)
        }
        
        return (url, nil)
    }
    
    func getPostLogoutRedirectUri() -> (URL?, Error?) {
        
        guard let url = URL(string: self.postLogoutRedirectUri) else {

            let error = ApplicationError(title: "Invalid Configuration Error", description: "The post logout redirect URI could not be parsed")
            return (nil, error)
        }
        
        return (url, nil)
    }
}
