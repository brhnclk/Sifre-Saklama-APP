import Foundation
extension UserDefaults {
    private enum Keys {
        static let pin = "AppPIN"
    }
    static var savedPIN: String {
        get {
            return UserDefaults.standard.string(forKey: Keys.pin) ?? "0000"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.pin)
            UserDefaults.standard.synchronize()
        }
    }
} 
