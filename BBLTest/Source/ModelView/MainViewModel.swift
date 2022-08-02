//
//  MainViewModel.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import Foundation
import SwiftCoroutine
class MainViewModel: ObservableObject {
    
    private let config: ApplicationConfig
    private let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private var unauthenticatedModel: UnauthenticatedViewModel?
    private var authenticatedModel: AuthenticatedViewModel?

    @Published var isAuthenticated = false
    
    init(config: ApplicationConfig, state: ApplicationStateManager, appauth: AppAuthHandler) {
        
        // Create globals
        self.config = try! ApplicationConfigLoader.load()
        self.state = ApplicationStateManager()
        self.appauth = AppAuthHandler(config: self.config)
        
        // These are created on first use
        self.unauthenticatedModel = nil
        self.authenticatedModel = nil
    }
    
    /*
     * Create on first use because Swift does not like passing the callback from the init function
     */
    func getUnauthenticatedViewModel() -> UnauthenticatedViewModel {
        
        if self.unauthenticatedModel == nil {
            self.unauthenticatedModel = UnauthenticatedViewModel(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoggedIn: self.onLoggedIn)
        }
    
        return self.unauthenticatedModel!
    }
    
    /*
     * Create on first use because Swift does not like passing the callback from the init function
     */
    func getAuthenticatedViewModel() -> AuthenticatedViewModel {
        
        if self.authenticatedModel == nil {
            self.authenticatedModel = AuthenticatedViewModel(
                config: self.config,
                state: self.state,
                appauth: self.appauth,
                onLoggedOut: self.onLoggedOut)
        }
    
        return self.authenticatedModel!
    }
    
    func onLoggedIn() {
        self.isAuthenticated = true
    }

    func onLoggedOut() {
        self.isAuthenticated = false
    }
}
