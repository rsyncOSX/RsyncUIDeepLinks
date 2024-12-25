// The Swift Programming Language
// https://docs.swift.org/swift-book

//
//  RsyncUIDeepLinks.swift
//  RsyncUI
//
//  Created by Thomas Evensen on 23/12/2024.
//

import Foundation

public enum DeeplinknavigationError: LocalizedError {
    case invalidurl
    case invalidscheme
    case noaction

    public var errorDescription: String? {
        switch self {
        case .invalidurl:
            "Invalid URL"
        case .invalidscheme:
            "Invalid URL scheme"
        case .noaction:
            "No action URL scheme"
        }
    }
}

public enum Deeplinknavigation: String {
    case quicktask
    case loadprofile
    case loadandestimateprofile
}

public struct DeeplinkQueryItem: Hashable {
    let host: Deeplinknavigation
    let queryItem: URLQueryItem?
}

@MainActor
public struct RsyncUIDeepLinks {
    public func validateScheme(_ url: URL) throws -> URLComponents? {
        guard url.scheme == "rsyncuiapp" else { throw DeeplinknavigationError.invalidscheme }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            return components
        } else {
            throw DeeplinknavigationError.invalidurl
        }
    }

    public func thrownoaction() throws {
        throw DeeplinknavigationError.noaction
    }
    
    public func handlevalidURL(_ url: URL) -> DeeplinkQueryItem? {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            if let queryItems = components.queryItems, queryItems.count == 1 {
                return withQueryItems(components)
            } else {
                return noQueryItems(components)
            }
        } else {
            return nil
        }
    }
    
/*
    // URL has to be verified ahead of calling this function
    public func handleURL (_ url: URL) -> DeeplinkQueryItem? {

        var components: URLComponents?

        do {
            components = try validateScheme(url)
        } catch let e {
            let error = e
            // propogateerror(error: error)
            return nil
        }

        if let components {
            if let queryItems = components.queryItems, queryItems.count == 1 {
                return withQueryItems(components)
            } else {
                return noQueryItems(components)
            }
        }
        
        do {
            try thrownoaction()
        } catch let e {
            // propogateerror(error: error)
            return nil
        }

        return nil
    }
*/
    public func withQueryItems(_ components: URLComponents) -> DeeplinkQueryItem? {
        
        // First check if there are queryItems and only one queryItem
        // rsyncuiapp://loadandestimateprofile?profile=Pictures
        // rsyncuiapp://loadandestimateprofile?profile=default
        // rsyncuiapp://loadprofile?profile=Samsung

        if let queryItems = components.queryItems, queryItems.count == 1 {
            // Iterate through the query items and store them in the dictionary
            for queryItem in queryItems {
                if let host = components.host {
                    switch host {
                    case Deeplinknavigation.loadprofile.rawValue:
                        let deepLinkQueryItem = DeeplinkQueryItem(host: .loadprofile, queryItem: queryItem)
                        return deepLinkQueryItem
                    case Deeplinknavigation.loadandestimateprofile.rawValue:
                        let deepLinkQueryItem = DeeplinkQueryItem(host: .loadandestimateprofile, queryItem: queryItem)
                        return deepLinkQueryItem
                    default:
                        return nil
                    }

                } else {
                    return nil
                }
            }
        }
        return nil
    }

    public func noQueryItems(_ components: URLComponents) -> DeeplinkQueryItem? {
        guard components.queryItems == nil else { return nil }
        // No queryItems found
        // rsyncuiapp://quicktask
        if let host = components.host {
            switch host {
            case Deeplinknavigation.quicktask.rawValue:
                let deepLinkQueryItem = DeeplinkQueryItem(host: .quicktask, queryItem: nil)
                return deepLinkQueryItem
            default:
                return nil
            }

        } else {
            return nil
        }
    }
    
    public init () {}
}
