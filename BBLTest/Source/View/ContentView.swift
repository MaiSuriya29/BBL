//
//  ContentView.swift
//  BBLTest
//
//  Created by Suriya on 1/8/2565 BE.
//

import SwiftUI
struct ContentView: View {
    @ObservedObject private var model: MainViewModel
    init(model: MainViewModel) {
        self.model = model
    }
    var body: some View {
        VStack {
     
            
            if(model.isAuthenticated){
                AuthenticatedView(model: self.model.getAuthenticatedViewModel())
            }else{
                UnauthenticatedView(model: self.model.getUnauthenticatedViewModel())
            }
        }
    }
}


