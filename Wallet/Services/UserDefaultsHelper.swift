//
//  UserDefaultsHelper.swift
//  Wallet
//
//  Created by Ganesh on 10/04/26.
//


import Foundation

class UserDefaultsHelper {
    
    static let shared = UserDefaultsHelper()
    
    private init() {}
    
    func set(_ value: Any, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getString(forKey key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    
    func getBool(forKey key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func getInt(forKey key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    func clearAll() {
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
    }
}



struct UserDefaultsKeys {
    static let isLoggedIn = "isLoggedIn"
}
