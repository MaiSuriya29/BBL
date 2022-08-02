//
//  Logger.swift
//  BBLTest
//
//  Created by Suriya on 2/8/2565 BE.
//

import os.log
struct Logger {
    
    static func error(data: String) {
        os_log("%s", type: .error, data)
    }

    static func info(data: String) {
        os_log("%s", type: .info, data)
    }

    static func debug(data: String) {
        os_log("%s", type: .debug, data)
    }
}
