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

public struct RsyncUIDeepLinks {
    let rsyncuischeme: String = "rsyncuiapp"

    /// Creates a deep link URL with the specified host and query items
    /// - Parameters:
    ///   - host: The deep link action (e.g., "quicktask", "loadprofile")
    ///   - queryitems: Array of URL query items
    /// - Returns: Constructed URL or nil if invalid
    /// - Example: `rsyncuiapp://loadprofile?profile=Pictures`
    public func createURL(_ host: String, _ queryitems: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = rsyncuischeme
        components.host = host
        components.queryItems = queryitems
        return components.url
    }

    /// Validates that a URL string is properly formatted
    /// - Parameter urlstring: The URL string to validate
    /// - Returns: true if valid
    /// - Throws: `DeeplinknavigationError.invalidurl` if URL is malformed or missing required components
    public func validateURLstring(_ urlstring: String) throws -> Bool {
        guard let url = URL(string: urlstring),
              url.host != nil && url.scheme != nil
        else {
            throw DeeplinknavigationError.invalidurl
        }
        return true
    }

    /// Validates that the URL scheme matches the expected rsyncuiapp scheme
    /// - Parameter url: The URL to validate
    /// - Returns: URLComponents if valid
    /// - Throws: `DeeplinknavigationError.invalidscheme` if scheme doesn't match, or `DeeplinknavigationError.invalidurl` if URL cannot be parsed
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

    /// Throws an error indicating no valid action was found
    /// - Throws: `DeeplinknavigationError.noaction`
    public func thrownoaction() throws {
        throw DeeplinknavigationError.noaction
    }

    /// Handles a validated URL by parsing its components and query items
    /// - Parameter urlcomponents: The URL components to process
    /// - Returns: DeeplinkQueryItem containing the parsed action and parameters, or nil if invalid
    public func handlevalidURL(_ urlcomponents: URLComponents) -> DeeplinkQueryItem? {
        if let queryItems = urlcomponents.queryItems, !queryItems.isEmpty {
            withQueryItems(urlcomponents)
        } else {
            noQueryItems(urlcomponents)
        }
    }

    /// Validates that a profile exists in the list of available profiles
    /// - Parameters:
    ///   - profile: The profile name to validate
    ///   - existingProfiles: Array of valid profile names
    /// - Throws: `NoValidProfileError.noprofile` if profile is not found
    public func validateprofile(_ profile: String, _ existingProfiles: [String]) throws {
        guard existingProfiles.contains(profile) else {
            throw NoValidProfileError.noprofile
        }
    }

    /// Validates that no other URL action is currently in progress
    /// - Parameter queryItems: Current query items to check
    /// - Throws: `OnlyoneURLactionError.onlyoneaction` if an action is already in progress
    public func validateNoOngoingURLAction(_ queryItems: URLQueryItem?) throws {
        guard queryItems == nil else {
            throw OnlyoneURLactionError.onlyoneaction
        }
    }

    /// Processes URLs with query items
    /// - Parameter components: The URL components containing query items
    /// - Returns: DeeplinkQueryItem with parsed action and parameters
    /// - Note: Supports URLs like:
    ///   - `rsyncuiapp://loadprofile?profile=Pictures`
    ///   - `rsyncuiapp://loadprofileandestimate?profile=default`
    ///   - `rsyncuiapp://loadprofileandverify?profile=Pictures`
    public func withQueryItems(_ components: URLComponents) -> DeeplinkQueryItem? {
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

    /// Processes URLs without query items
    /// - Parameter components: The URL components to process
    /// - Returns: DeeplinkQueryItem with parsed action
    /// - Note: Supports URLs like: `rsyncuiapp://quicktask`
    public func noQueryItems(_ components: URLComponents) -> DeeplinkQueryItem? {
        guard components.queryItems == nil else { return nil }
        
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
