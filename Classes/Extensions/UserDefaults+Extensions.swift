//
//  UserDefaults.swift
//  AJRInterface
//
//  Created by AJ Raftis on 10/26/21.
//

import AJRFoundation

extension NSFont : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> NSFont? {
        let string = userDefaults.string(forKey:key)
        return string == nil ? nil : AJRFontFromString(string!)
    }
    
    public static func setUserDefault(_ value: NSFont?, forKey key: String, into userDefaults: UserDefaults) {
        userDefaults.set(value == nil ? nil : AJRStringFromFont(value!), forKey:key)
    }
    
}
