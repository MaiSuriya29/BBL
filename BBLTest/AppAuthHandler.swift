//
//  AppAuthHandler.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import AppAuth
import SwiftCoroutine
class AppAuthHandler {
    private let config: ApplicationConfig
    private var userAgentSession: OIDExternalUserAgentSession?
    
    init(config: ApplicationConfig) {
        self.config = config
        self.userAgentSession = nil
    }
    /*
     * Get OpenID Connect endpoints
     */
    func fetchMetadata() throws -> CoFuture<OIDServiceConfiguration> {
        
        let promise = CoPromise<OIDServiceConfiguration>()
        
        let (issuerUrl, parseError) = self.config.getIssuerUri()
        if issuerUrl == nil {
            promise.fail(parseError!)
            return promise
        }
      
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuerUrl!) { metadata, ex in

            if metadata != nil {
                
                Logger.info(data: "Metadata retrieved successfully")
                Logger.debug(data: metadata!.description)
                promise.success(metadata!)

            } else {

                let error = self.createAuthorizationError(title: "Metadata Download Error", ex: ex)
                promise.fail(error)
            }
        }
        
        return promise
    }

    /*
     * Trigger a redirect with standard parameters
     * acr_values can be sent as an extra parameter, to control authentication methods
     */
    func performAuthorizationRedirect(
        metadata: OIDServiceConfiguration,
        clientID: String,
        viewController: UIViewController) -> CoFuture<OIDAuthorizationResponse?> {
        
        let promise = CoPromise<OIDAuthorizationResponse?>()
        
        let (redirectUri, parseError) = self.config.getRedirectUri()
        if redirectUri == nil {
            promise.fail(parseError!)
            return promise
        }

        // Use acr_values to select a particular authentication method at runtime
        let extraParams = [String: String]()
        // extraParams["acr_values"] = "urn:se:curity:authentication:html-form:Username-Password"
        
        let scopesArray = self.config.scope.components(separatedBy: " ")
        let request = OIDAuthorizationRequest(
            configuration: metadata,
            clientId: clientID,
            clientSecret: nil,
            scopes: scopesArray,
            redirectURL: redirectUri!,
            responseType: OIDResponseTypeCode,
            additionalParameters: extraParams)

        let userAgent = OIDExternalUserAgentIOS(presenting: viewController)
        self.userAgentSession = OIDAuthorizationService.present(request, externalUserAgent: userAgent!) { response, ex in
            
            if response != nil {
                
                Logger.info(data: "Authorization response received successfully")
                let code = response!.authorizationCode == nil ? "" : response!.authorizationCode!
                let state = response!.state == nil ? "" : response!.state!
                Logger.debug(data: "CODE: \(code), STATE: \(state)")

                promise.success(response!)

            } else {
                
                if ex != nil && self.isUserCancellationErrorCode(ex: ex!) {
                    
                    Logger.info(data: "User cancelled the ASWebAuthenticationSession window")
                    promise.success(nil)

                } else {

                    
                    let error = self.createAuthorizationError(title: "Authorization Request Error", ex: ex)
                    promise.fail(error)
                }
            }
            
            self.userAgentSession = nil
        }
        
        return promise
    }
    
    /*
     * Handle the authorization response, including the user closing the Chrome Custom Tab
     */
    func redeemCodeForTokens(
        clientID: String,
        authResponse: OIDAuthorizationResponse) -> CoFuture<OIDTokenResponse> {

        let promise = CoPromise<OIDTokenResponse>()

        var extraParams = [String: String]()
            extraParams["Grant Type"] = "Authorization Code Flow"
            extraParams["client_secret"] = "zWp1vmGR9M2PZcGbXe1WEoG2eu5tazeCdgu0K9O00RhvlTSjBcZI-xcJV4NG5MNj"
        let request = authResponse.tokenExchangeRequest(withAdditionalParameters: extraParams)
        OIDAuthorizationService.perform(
            request!,
            originalAuthorizationResponse: authResponse) { tokenResponse, ex in

            if tokenResponse != nil {

                Logger.info(data: "Authorization code grant response received successfully")
                let accessToken = tokenResponse!.accessToken == nil ? "" : tokenResponse!.accessToken!
                let refreshToken = tokenResponse!.refreshToken == nil ? "" : tokenResponse!.refreshToken!
                let idToken = tokenResponse!.idToken == nil ? "" : tokenResponse!.idToken!
                Logger.debug(data: "AT: \(accessToken), RT: \(refreshToken), IDT: \(idToken)" )

                
                promise.success(tokenResponse!)

            } else {

                let error = self.createAuthorizationError(title: "Authorization Response Error", ex: ex)
                promise.fail(error)
            }
        }
        
        return promise
    }

    /*
     * Try to refresh an access token and return null when the refresh token expires
     */
    func refreshAccessToken(
            metadata: OIDServiceConfiguration,
            clientID: String,
            refreshToken: String) -> CoFuture<OIDTokenResponse?> {
        
        let promise = CoPromise<OIDTokenResponse?>()
        
        let request = OIDTokenRequest(
            configuration: metadata,
            grantType: OIDGrantTypeRefreshToken,
            authorizationCode: nil,
            redirectURL: nil,
            clientID: clientID,
            clientSecret: nil,
            scope: nil,
            refreshToken: refreshToken,
            codeVerifier: nil,
            additionalParameters: nil)
        
        OIDAuthorizationService.perform(request) { tokenResponse, ex in

            if tokenResponse != nil {

                Logger.info(data: "Refresh token code grant response received successfully")
                let accessToken = tokenResponse!.accessToken == nil ? "" : tokenResponse!.accessToken!
                let refreshToken = tokenResponse!.refreshToken == nil ? "" : tokenResponse!.refreshToken!
                let idToken = tokenResponse!.idToken == nil ? "" : tokenResponse!.idToken!
                Logger.debug(data: "AT: \(accessToken), RT: \(refreshToken), IDT: \(idToken)" )

                promise.success(tokenResponse!)

            } else {
                
                if ex != nil && self.isRefreshTokenExpiredErrorCode(ex: ex!) {
                    
                    Logger.info(data: "Refresh token expired and the user must re-authenticate")
                    promise.success(nil)

                } else {

                    let error = self.createAuthorizationError(title: "Refresh Token Error", ex: ex)
                    promise.fail(error)
                }
            }
        }
        
        return promise
    }

    /*
     * Do an OpenID Connect end session redirect and remove the SSO cookie
     */
    func performEndSessionRedirect(metadata: OIDServiceConfiguration,
                                   idToken: String,
                                   viewController: UIViewController) -> CoFuture<Void> {
        
        let promise = CoPromise<Void>()
        let extraParams = [String: String]()

        let (postLogoutRedirectUri, parseError) = self.config.getPostLogoutRedirectUri()
        if postLogoutRedirectUri == nil {
            promise.fail(parseError!)
            return promise
        }
        
        let request = OIDEndSessionRequest(
            configuration: metadata,
            idTokenHint: idToken,
            postLogoutRedirectURL: postLogoutRedirectUri!,
            additionalParameters: extraParams)

        let userAgent = OIDExternalUserAgentIOS(presenting: viewController)
        self.userAgentSession = OIDAuthorizationService.present(request, externalUserAgent: userAgent!) { response, ex in
            
            if ex != nil {
                
                if self.isUserCancellationErrorCode(ex: ex!) {
                
                    Logger.info(data: "User cancelled the ASWebAuthenticationSession window")
                    promise.success(Void())

                } else {

                    let error = self.createAuthorizationError(title: "End Session Error", ex: ex)
                    promise.fail(error)
                }

            } else {
                
                promise.success(Void())
            }
            
            self.userAgentSession = nil
        }
        
        return promise
    }

    /*
     * We can check for specific error codes to handle the user cancelling the ASWebAuthenticationSession window
     */
    private func isUserCancellationErrorCode(ex: Error) -> Bool {

        let error = ex as NSError
        return error.domain == OIDGeneralErrorDomain && error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue
    }
    
    /*
     * We can check for a specific error code when the refresh token expires and the user needs to re-authenticate
     */
    private func isRefreshTokenExpiredErrorCode(ex: Error) -> Bool {

        let error = ex as NSError
        return error.domain == OIDOAuthTokenErrorDomain && error.code == OIDErrorCodeOAuth.invalidGrant.rawValue
    }

    /*
     * Process standard OAuth error / error_description fields and also AppAuth error identifiers
     */
    private func createAuthorizationError(title: String, ex: Error?) -> ApplicationError {
        
        var parts = [String]()
        if (ex == nil) {

            parts.append("Unknown Error")

        } else {

            let nsError = ex! as NSError
            
            if nsError.domain.contains("org.openid.appauth") {
                parts.append("(\(nsError.domain) / \(String(nsError.code)))")
            }

            if !ex!.localizedDescription.isEmpty {
                parts.append(ex!.localizedDescription)
            }
        }

        let fullDescription = parts.joined(separator: " : ")
        let error = ApplicationError(title: title, description: fullDescription)
        Logger.error(data: "\(error.title) : \(error.description)")
        return error
    }
    
}
