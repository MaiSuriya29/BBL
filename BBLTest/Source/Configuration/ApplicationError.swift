//
//  ApplicationError.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import Foundation
class ApplicationError: Error {
    
    var title: String
    var description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}
