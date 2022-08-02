//
//  ApplicationConfigLoader.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import Foundation
struct ApplicationConfigLoader {

    static func load() throws -> ApplicationConfig {

        let configFilePath = Bundle.main.path(forResource: "config", ofType: "json")
        let jsonText = try String(contentsOfFile: configFilePath!)
        let jsonData = jsonText.data(using: .utf8)!
        let decoder = JSONDecoder()

        let data =  try decoder.decode(ApplicationConfig.self, from: jsonData)
        return data
    }
}
