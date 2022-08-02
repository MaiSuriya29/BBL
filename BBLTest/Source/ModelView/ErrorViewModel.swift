//
//  ErrorViewModel.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import SwiftUI
class ErrorViewModel: ObservableObject {

    @Published var title = ""
    @Published var description = ""
    
    init(error: ApplicationError) {
        self.title = error.title
        self.description = error.description.isEmpty ? "Unknown Error" : error.description
    }

    func clearDetails() {
        self.title = ""
        self.description = ""
    }

    func hasDetails() -> Bool {
        return !self.title.isEmpty
    }
}
