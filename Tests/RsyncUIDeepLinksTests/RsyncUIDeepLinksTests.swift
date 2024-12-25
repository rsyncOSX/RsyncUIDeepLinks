@testable import RsyncUIDeepLinks

import Testing
import Foundation

@Suite final class TestRsyncUIDeepLinks {
    
    // rsyncuiapp://loadandestimateprofile?profile=Pictures
    // rsyncuiapp://loadandestimateprofile?profile=default
    // rsyncuiapp://loadprofile?profile=Samsung
    // rsyncuiapp://quicktask
    
    var url1: URL? { URL(string: "rsyncuiapp://loadandestimateprofile?profile=Pictures") }
    var url2: URL? { URL(string: "rsyncuiapp://loadandestimateprofile?profile=default") }
    var url3: URL? { URL(string: "rsyncuiapp://loadprofile?profile=Samsung") }
    var url4: URL? { URL(string: "rsyncuiapp://quicktask") }

    
    @Test func URLstring1() async {
        
        let rsyncUIDeepLinks =  await RsyncUIDeepLinks()
        
        if let url1  {
            do {
                if let components = try await rsyncUIDeepLinks.validateScheme(url1) {
                    if let test =  await rsyncUIDeepLinks.handlevalidURL(components) {
                        print(test)
                    } else {
                        print("No action")
                    }
                }
            } catch  {
                print("Error: \(error)")
            }
        }
    }
    
    @Test func URLstring2() async {
        
        let rsyncUIDeepLinks =  await RsyncUIDeepLinks()
        
        if let url2  {
            do {
                if let components = try await rsyncUIDeepLinks.validateScheme(url2) {
                    if let test =  await rsyncUIDeepLinks.handlevalidURL(components) {
                        print(test)
                    } else {
                        print("No action")
                    }
                }
            } catch  {
                print("Error: \(error)")
            }
        }
    }
    
    @Test func URLstring3() async {
        
        let rsyncUIDeepLinks =  await RsyncUIDeepLinks()
        
        if let url3  {
            do {
                if let components = try await rsyncUIDeepLinks.validateScheme(url3) {
                    if let test =  await rsyncUIDeepLinks.handlevalidURL(components) {
                        print(test)
                    } else {
                        print("No action")
                    }
                }
            } catch  {
                print("Error: \(error)")
            }
        }
    }
    
    @Test func URLstring4() async {
        
        let rsyncUIDeepLinks =  await RsyncUIDeepLinks()
        
        if let url4  {
            do {
                if let components = try await rsyncUIDeepLinks.validateScheme(url4) {
                    if let test =  await rsyncUIDeepLinks.handlevalidURL(components) {
                        print(test)
                    } else {
                        print("No action")
                    }
                }
            } catch  {
                print("Error: \(error)")
            }
        }
    }
}
