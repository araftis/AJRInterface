
import Foundation

extension NSColor : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key: String, from userDefaults: UserDefaults) -> NSColor? {
        if let string = userDefaults.string(forKey: key) {
            return AJRColorFromString(string)
        }
        return nil;
    }
    
    public static func setUserDefault(_ value: NSColor?, forKey key: String, into userDefaults: UserDefaults) {
        if let value = value {
            userDefaults.set(AJRStringFromColor(value), forKey: key);
        } else {
            userDefaults.set(nil, forKey: key)
        }
    }
    
}
