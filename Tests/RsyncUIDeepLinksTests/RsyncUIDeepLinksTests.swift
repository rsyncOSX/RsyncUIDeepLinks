@testable import RsyncUIDeepLinks

import Foundation
import OSLog
import Testing

@Suite final class TestRsyncUIDeepLinks {
    // rsyncuiapp://loadandestimateprofile?profile=Pictures
    // rsyncuiapp://loadandestimateprofile?profile=default
    // rsyncuiapp://loadprofile?profile=Samsung
    // rsyncuiapp://quicktask¨
    // rsyncuiapp://loadprofileandverify?profile=Pictures&id=Pictures_backup - multiple queryItems, separated by &

    var url1: URL? { URL(string: "rsyncuiapp://loadprofileandestimate?profile=Pictures") }
    var url2: URL? { URL(string: "rsyncuiapp://loadprofileandestimate?profile=default") }
    var url3: URL? { URL(string: "rsyncuiapp://loadprofile?profile=Samsung") }
    var url4: URL? { URL(string: "rsyncuiapp://quicktask") }
    var url5: URL? { URL(string: "rsyncuiapp://loadprofileandverify?profile=Pictures&id=Pictures_backup") }

    @Test func URLstring1() async {
        let rsyncUIDeepLinks = await RsyncUIDeepLinks()
        let truth = DeeplinkQueryItem(host: .loadprofileandestimate,
                                      queryItems: [URLQueryItem(name: "profile", value: "Pictures")])

        if let url1 {
            do {
                if let components = try await rsyncUIDeepLinks.validateScheme(url1) {
                    if let test = await rsyncUIDeepLinks.handlevalidURL(components) {
                        #expect(test == truth)
                        await handleURLsidebarmainView(url1)
                    } else {
                        Logger.process.warning("No action")
                    }
                }
            } catch {
                Logger.process.warning("Error: \(error)")
            }
        }
    }

    @Test func URLstring2() async {
        let rsyncUIDeepLinks = await RsyncUIDeepLinks()
        let truth = DeeplinkQueryItem(host: .loadprofileandestimate,
                                      queryItems: [URLQueryItem(name: "profile", value: "default")])

        if let url2 {
            do {
                if let components = try await rsyncUIDeepLinks.validateScheme(url2) {
                    if let test = await rsyncUIDeepLinks.handlevalidURL(components) {
                        #expect(test == truth)
                        await handleURLsidebarmainView(url2)
                    } else {
                        Logger.process.warning("No action")
                    }
                }
            } catch {
                Logger.process.warning("Error: \(error)")
            }
        }
    }

    @Test func URLstring3() async {
        let rsyncUIDeepLinks = await RsyncUIDeepLinks()
        let truth = DeeplinkQueryItem(host: .loadprofile,
                                      queryItems: [URLQueryItem(name: "profile", value: "Samsung")])

        if let url3 {
            do {
                if let components = try await rsyncUIDeepLinks.validateScheme(url3) {
                    if let test = await rsyncUIDeepLinks.handlevalidURL(components) {
                        #expect(test == truth)
                        await handleURLsidebarmainView(url3)
                    } else {
                        Logger.process.warning("No action")
                    }
                }
            } catch {
                Logger.process.warning("Error: \(error)")
            }
        }
    }

    @Test func URLstring4() async {
        let rsyncUIDeepLinks = await RsyncUIDeepLinks()
        let truth = DeeplinkQueryItem(host: .quicktask,
                                      queryItems: nil)

        if let url4 {
            do {
                if let components = try await rsyncUIDeepLinks.validateScheme(url4) {
                    if let test = await rsyncUIDeepLinks.handlevalidURL(components) {
                        #expect(test == truth)
                        await handleURLsidebarmainView(url4)
                    } else {
                        Logger.process.warning("No action")
                    }
                }
            } catch {
                Logger.process.warning("Error: \(error)")
            }
        }
    }

    @Test func URLstring5() async {
        let rsyncUIDeepLinks = await RsyncUIDeepLinks()
        let truth = DeeplinkQueryItem(host: .loadprofileandverify,
                                      queryItems: [URLQueryItem(name: "profile", value: "Pictures"),
                                                   URLQueryItem(name: "id", value: "Pictures_backup")])
        if let url5 {
            do {
                if let components = try await rsyncUIDeepLinks.validateScheme(url5) {
                    if let test = await rsyncUIDeepLinks.handlevalidURL(components) {
                        #expect(test == truth)
                        await handleURLsidebarmainView(url5)
                    } else {
                        Logger.process.warning("No action")
                    }
                }
            } catch {
                Logger.process.warning("Error: \(error)")
            }
        }
    }

    private func handleURLsidebarmainView(_ url: URL) async {
        switch await handleURL(url)?.host {
        case .quicktask:
            Logger.process.info("handleURLsidebarmainView: URL Quicktask - \(url)")
            Logger.process.info("selectedview = .synchronize")
            Logger.process.info("executetasknavigation.append(Tasks(task: .quick_synchronize")
        case .loadprofile:
            if let queryitem = await handleURL(url)?.queryItems, queryitem.count == 1 {
                let profile = queryitem[0].value ?? ""
                if validateprofile(profile) {
                    Logger.process.info("selectedprofile \(profile)")
                }
            } else {
                return
            }
        case .loadprofileandestimate:
            Logger.process.info("handleURLsidebarmainView: URL Loadprofile and Estimate - \(url)")
            if let queryitems = await handleURL(url)?.queryItems, queryitems.count == 1 {
                let profile = queryitems[0].value ?? ""
                Logger.process.info("selectedprofile \(profile)")
                Logger.process.info("selectedview = .synchronize")

                if profile == "default" {
                    Logger.process.info("Observe queryitem")
                    Logger.process.info("queryitem \(queryitems[0])")
                } else {
                    if validateprofile(profile) {
                        Logger.process.info("Observe queryitem")
                        Logger.process.info("queryitem \(queryitems[0])")
                    }
                }
            } else {
                return
            }
        case .loadprofileandverify:
            Logger.process.info("handleURLsidebarmainView: URL Loadprofile and Verify - \(url)")
            if let queryitems = await handleURL(url)?.queryItems, queryitems.count == 2 {
                let profile = queryitems[0].value ?? ""
                Logger.process.info("selectedprofile \(profile)")
                Logger.process.info("selectedview = .verify_remote")
                
                if profile == "default" {
                    Logger.process.info("Observe queryitem")
                    Logger.process.info("queryitem \(queryitems[1])")
                } else {
                    if validateprofile(profile) {
                        Logger.process.info("Observe queryitem")
                        Logger.process.info("queryitem \(queryitems[1])")
                    }
                }

            } else {
                return
            }
        default:
            return
        }
    }

    func handleURL(_ url: URL) async -> DeeplinkQueryItem? {
        let rsyncUIDeepLinks = await RsyncUIDeepLinks()
        do {
            if let components = try await rsyncUIDeepLinks.validateScheme(url) {
                if let deepLinkQueryItem = await rsyncUIDeepLinks.handlevalidURL(components) {
                    return deepLinkQueryItem
                } else {
                    do {
                        try await rsyncUIDeepLinks.thrownoaction()
                    } catch let e {
                        let error = e
                        Logger.process.warning("handleURL: Error - \(error)")
                    }
                }
            }

        } catch let e {
            let error = e
            Logger.process.warning("handleURL: Error - \(error)")
        }
        return nil
    }

    func validateprofile(_: String) -> Bool {
        true
    }
}

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let process = Logger(subsystem: subsystem, category: "process")
}
