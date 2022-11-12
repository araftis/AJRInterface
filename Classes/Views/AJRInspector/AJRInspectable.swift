//
//  AJRInspectable.swift
//  AJRInterface
//
//  Created by AJ Raftis on 11/11/22.
//

import Foundation

public extension AJRInspectorContentIdentifier {
    
    static func == (left: AJRInspectorContentIdentifier, right: AJRInspectorContentIdentifier) -> Bool {
        return left.rawValue == right.rawValue
    }
    
}

extension AJRInspectorContentIdentifier : AJRUserDefaultProvider {

    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> AJRInspectorContentIdentifier? {
        if let raw = userDefaults.string(forKey: key) {
            return AJRInspectorContentIdentifier(raw)
        }
        return nil
    }
    
    public static func setUserDefault(_ value: AJRInspectorContentIdentifier?, forKey key: String, into userDefaults: UserDefaults) {
        if let value {
            userDefaults.set(value.rawValue, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }
    
}
