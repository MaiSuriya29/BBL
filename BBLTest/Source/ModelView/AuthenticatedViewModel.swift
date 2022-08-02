//
//  AuthenticatedViewModel.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import Foundation
import SwiftCoroutine
import AppAuth
import SwiftJWT

class AuthenticatedViewModel : ObservableObject{
    private let config: ApplicationConfig
    private let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private let onLoggedOut: (() -> Void)

    @Published var hasRefreshToken: Bool
    @Published var hasIdToken: Bool
    @Published var userData: UserModel?
    @Published var accessToken: String
    @Published var refreshToken: String
    @Published var error: ApplicationError?
    
    struct IDTokenClaims: Claims {
        var sub: String
    }
    
    init(
        config: ApplicationConfig,
        state: ApplicationStateManager,
        appauth: AppAuthHandler,
        onLoggedOut: @escaping () -> Void) {

        self.config = config
        self.state = state
        self.appauth = appauth
        self.onLoggedOut = onLoggedOut
        self.hasRefreshToken = false
        self.hasIdToken = false
        self.userData = nil
        self.accessToken = ""
        self.refreshToken = ""
        self.error = nil
    }

    /*
     * Show token information after login
     */
    func processTokens() {

        if self.state.tokenResponse?.accessToken != nil {
            self.accessToken = self.state.tokenResponse!.accessToken!
        }

        if self.state.tokenResponse?.refreshToken != nil {
            self.hasRefreshToken = true
            self.refreshToken = self.state.tokenResponse!.refreshToken!
        }
        
        if self.state.idToken != nil {
            
            let idToken = self.state.idToken!
            self.hasIdToken = true
            
            do {

                let jwt = try JWT<UserModel>(jwtString: idToken)
                self.userData = jwt.claims
      

            } catch {
                
                let appError = ApplicationError(title: "Failed to parse ID Token", description: error.localizedDescription)
                Logger.error(data: appError.description)
                self.error = appError
            }
        }
    }

    /*
     * Perform a refresh token grant message
     */
    func refreshAccessToken() {
        
        DispatchQueue.main.startCoroutine {

            do {

                let metadata = self.state.metadata!
                let refreshToken = self.state.tokenResponse!.refreshToken!
                var tokenResponse: OIDTokenResponse? = nil
                self.error = nil

                try DispatchQueue.global().await {

                    tokenResponse = try self.appauth.refreshAccessToken(
                        metadata: metadata,
                        clientID: self.config.clientID,
                        refreshToken: refreshToken).await()
                }
                
                if tokenResponse != nil {
                    self.state.saveTokens(tokenResponse: tokenResponse!)
                    self.processTokens()
                    
                } else {
                    self.state.clearTokens()
                    self.onLoggedOut()
                }
                

            } catch {
                
                let appError = error as? ApplicationError
                if appError != nil {
                    self.error = appError!
                }
            }
        }
    }
    
    /*
     * Run the end session redirect and handle the response
     */
    func startLogout() {

        DispatchQueue.main.startCoroutine {

            do {

                self.error = nil

                try self.appauth.performEndSessionRedirect(
                    metadata: self.state.metadata!,
                    idToken: self.state.idToken!,
                    viewController: self.getViewController()
                ).await()

                self.state.clearTokens()
                self.onLoggedOut()

            } catch {
                
                let appError = error as? ApplicationError
                if appError != nil {
                    self.error = appError!
                }
            }
        }
    }

    private func getViewController() -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
}
