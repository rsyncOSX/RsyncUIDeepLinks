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
            "Invalid URL scheme, scheme should be rsyncuiapp"
        case .noaction:
            "No action defined for URL scheme"
        }
    }
}

public enum NoValidProfileError: LocalizedError {
    case noprofile

    public var errorDescription: String? {
        "No valid profile found"
    }
}

public enum OnlyoneURLactionError: LocalizedError {
    case onlyoneaction

    public var errorDescription: String? {
        "Only one URL action at a time is allowed"
    }
}

public enum Deeplinknavigation: String, Sendable {
    case quicktask
    case loadprofile
    case loadprofileandestimate
    case loadprofileandverify
}

public enum QueryItemNames: String, Sendable {
    case profile
}

public struct DeeplinkQueryItem: Hashable, Sendable {
    public let host: Deeplinknavigation
    public let queryItems: [URLQueryItem]?
}

@MainActor
public struct RsyncUIDeepLinks {
    
    let rsyncuischeme: String = "rsyncuiapp"
    
    public func createURL(_ host: String, _ queryitems: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = rsyncuischeme
        components.host = host
        components.queryItems = queryitems.map({ item in
            return item
        })
        return components.url
    }
    
    public func validateURLstring(_ urlstring: String) throws -> Bool {
        if let url = URL(string: urlstring) {
            guard url.scheme == rsyncuischeme else {
                throw DeeplinknavigationError.invalidscheme
            }
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                return true
            } else {
                throw DeeplinknavigationError.invalidurl
            }
        } else {
            throw DeeplinknavigationError.invalidurl
        }
    }
    
    
    public func validateScheme(_ url: URL) throws -> URLComponents? {
        guard url.scheme == rsyncuischeme else {
            throw DeeplinknavigationError.invalidscheme
        }
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            return components
        } else {
            throw DeeplinknavigationError.invalidurl
        }
    }

    public func thrownoaction() throws {
        throw DeeplinknavigationError.noaction
    }

    public func handlevalidURL(_ urlcomponents: URLComponents) -> DeeplinkQueryItem? {
        if let queryItems = urlcomponents.queryItems, queryItems.count > 0 {
            withQueryItems(urlcomponents)
        } else {
            noQueryItems(urlcomponents)
        }
    }

    public func validateprofile(_ profile: String, _ existingProfiles: [String]) throws {
        guard existingProfiles.contains(profile) else {
            throw NoValidProfileError.noprofile
        }
    }
    
    public func validatenoongoingURLaction(_ quyerItems: URLQueryItem?) throws  {
        guard quyerItems == nil else {
            throw OnlyoneURLactionError.onlyoneaction
        }
    }
    
    public func withQueryItems(_ components: URLComponents) -> DeeplinkQueryItem? {
        // First check if there are queryItems and only one queryItem
        // rsyncuiapp://loadprofileandestimate?profile=Pictures
        // rsyncuiapp://loadprofileandestimate?profile=default
        // rsyncuiapp://loadprofile?profile=Samsung
        // rsyncuiapp://loadprofileandverify?profile=Pictures
        // rsyncuiapp://loadprofileandverify?profile=Pictures&id=Pictures_backup

        if let queryItems = components.queryItems {
            if let host = components.host,
               let queryitemname = queryItems.first?.name,
               queryitemname == QueryItemNames.profile.rawValue {
                switch host {
                case Deeplinknavigation.loadprofile.rawValue:
                    let deepLinkQueryItem = DeeplinkQueryItem(host: .loadprofile, queryItems: queryItems)
                    return deepLinkQueryItem
                case Deeplinknavigation.loadprofileandestimate.rawValue:
                    let deepLinkQueryItem = DeeplinkQueryItem(host: .loadprofileandestimate, queryItems: queryItems)
                    return deepLinkQueryItem
                case Deeplinknavigation.loadprofileandverify.rawValue:
                    let deepLinkQueryItem = DeeplinkQueryItem(host: .loadprofileandverify, queryItems: queryItems)
                    return deepLinkQueryItem
                default:
                    return nil
                }
            } else {
                return nil
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
                let deepLinkQueryItem = DeeplinkQueryItem(host: .quicktask, queryItems: nil)
                return deepLinkQueryItem
            default:
                return nil
            }

        } else {
            return nil
        }
    }

    public init() {}
}
