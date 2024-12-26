@testable import RsyncUIDeepLinks

import Foundation
import Testing

@Suite final class TestRsyncUIDeepLinks {
    // rsyncuiapp://loadandestimateprofile?profile=Pictures
    // rsyncuiapp://loadandestimateprofile?profile=default
    // rsyncuiapp://loadprofile?profile=Samsung
    // rsyncuiapp://quicktask¨
    // rsyncuiapp://loadprofileandverify?profile=Pictures&task=first - multiple queryItems, separated by &

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
                    } else {
                        print("No action")
                    }
                }
            } catch {
                print("Error: \(error)")
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
                    } else {
                        print("No action")
                    }
                }
            } catch {
                print("Error: \(error)")
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
                    } else {
                        print("No action")
                    }
                }
            } catch {
                print("Error: \(error)")
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
                    } else {
                        print("No action")
                    }
                }
            } catch {
                print("Error: \(error)")
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
                    } else {
                        print("No action")
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
