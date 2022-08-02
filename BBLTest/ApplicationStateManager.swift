//
//  ApplicationStateManager.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import AppAuth
import SwiftKeychainWrapper
class ApplicationStateManager  {
    private var authState: OIDAuthState
    private var metadataValue: OIDServiceConfiguration? = nil
    var idToken: String? = nil
    private var storageKey = "io.curity.client"
    
    /*
     * Initialize the app's state when it starts
     */
    init() {
        self.authState = OIDAuthState(
            authorizationResponse: nil,
            tokenResponse: nil,
            registrationResponse: nil
        )
    }
    /*
     * Store tokens in memory
     */
    func saveTokens(tokenResponse: OIDTokenResponse) {
        
        // When refreshing tokens, the Curity Identity Server does not issue a new ID token
        // The AppAuth code does not allow us to update the token response with the original ID token
        // Therefore we store the ID token separately
        if (tokenResponse.idToken != nil) {
            self.idToken = tokenResponse.idToken
        }
    
        self.authState.update(with: tokenResponse, error: nil)
    }
    
    /*
     * Clear tokens upon logout or when the session expires
     */
    func clearTokens() {
        self.authState = OIDAuthState(authorizationResponse: nil, tokenResponse: nil, registrationResponse: nil)
        self.idToken = nil
        
        // KeychainWrapper.standard.removeObject(forKey: self.storageKey + ".token")
    }
    
    var metadata: OIDServiceConfiguration? {
        get {
            return self.metadataValue
        }
        set(value) {
            self.metadataValue = value
        }
    }
    
    var tokenResponse: OIDTokenResponse? {
        get {
            return self.authState.lastTokenResponse
        }
    }
}
