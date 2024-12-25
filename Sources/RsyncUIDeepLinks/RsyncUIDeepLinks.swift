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

public enum Deeplinknavigation: String, Sendable {
    case quicktask
    case loadprofile
    case loadandestimateprofile
}


public struct DeeplinkQueryItem: Hashable, Sendable {
    public let host: Deeplinknavigation
    public let queryItem: URLQueryItem?
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

    public func handlevalidURL(_ urlcomponents: URLComponents) -> DeeplinkQueryItem? {
        if let queryItems = urlcomponents.queryItems, queryItems.count == 1 {
            withQueryItems(urlcomponents)
        } else {
            noQueryItems(urlcomponents)
        }
    }

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

    public init() {}
}
