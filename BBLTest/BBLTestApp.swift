//
//  BBLTestApp.swift
//  BBLTest
//
//  Created by Suriya on 1/8/2565 BE.
//

import SwiftUI

@main
struct BBLTestApp: App {
    private let config: ApplicationConfig
    private let state: ApplicationStateManager
    private let appauth: AppAuthHandler
    private let model: MainViewModel
    init() {
        self.config = try! ApplicationConfigLoader.load()
        self.state = ApplicationStateManager()
        self.appauth = AppAuthHandler(config: self.config)
        self.model = MainViewModel(config: self.config, state: self.state, appauth: self.appauth)
    }
    var body: some Scene {
        WindowGroup {
            ContentView(model: self.model)
        }
    }
}
