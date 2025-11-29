## Hi there 👋

This package is code for creating valid URL links.

# RsyncUIDeepLinks Documentation

A Swift package for handling deep link navigation in RsyncUI applications using a custom URL scheme.

## Overview

RsyncUIDeepLinks provides a type-safe way to create, validate, and handle deep links for the RsyncUI application. It uses the custom URL scheme `rsyncuiapp://` to enable external applications or scripts to trigger specific actions within RsyncUI.

## URL Scheme

All deep links use the `rsyncuiapp://` scheme with the following format:

```
rsyncuiapp://action?parameter=value
```

## Supported Actions

### Quick Task
Triggers a quick task without requiring a profile.

```
rsyncuiapp://quicktask
```

### Load Profile
Loads a specific profile.

```
rsyncuiapp://loadprofile?profile=Pictures
```

### Load Profile and Estimate
Loads a profile and performs an estimate operation.

```
rsyncuiapp://loadprofileandestimate?profile=default
```

## Usage

### Initialization

```swift
let deepLinks = RsyncUIDeepLinks()
```

### Creating Deep Link URLs

```swift
let deepLinks = RsyncUIDeepLinks()

// Create a quick task URL
if let url = deepLinks.createURL("quicktask", []) {
    print(url) // rsyncuiapp://quicktask
}

// Create a load profile URL
let queryItems = [URLQueryItem(name: "profile", value: "Pictures")]
if let url = deepLinks.createURL("loadprofile", queryItems) {
    print(url) // rsyncuiapp://loadprofile?profile=Pictures
}
```

### Validating URL Strings

```swift
let urlString = "rsyncuiapp://loadprofile?profile=Pictures"

do {
    if try deepLinks.validateURLstring(urlString) {
        print("URL is valid")
    }
} catch DeeplinknavigationError.invalidurl {
    print("Invalid URL format")
}
```

### Validating URL Scheme

```swift
guard let url = URL(string: "rsyncuiapp://quicktask") else { return }

do {
    if let components = try deepLinks.validateScheme(url) {
        print("Scheme is valid")
        // Process components
    }
} catch DeeplinknavigationError.invalidscheme {
    print("Wrong URL scheme - expected rsyncuiapp")
} catch DeeplinknavigationError.invalidurl {
    print("Cannot parse URL")
}
```

### Complete Deep Link Handling Flow

```swift
let deepLinks = RsyncUIDeepLinks()
let urlString = "rsyncuiapp://loadprofile?profile=Pictures"

do {
    // Step 1: Validate URL string format
    guard try deepLinks.validateURLstring(urlString),
          let url = URL(string: urlString) else {
        return
    }
    
    // Step 2: Validate scheme and get components
    guard let components = try deepLinks.validateScheme(url) else {
        return
    }
    
    // Step 3: Handle the validated URL
    if let queryItem = deepLinks.handlevalidURL(components) {
        switch queryItem.host {
        case .quicktask:
            print("Execute quick task")
            
        case .loadprofile:
            if let profileName = queryItem.queryItems?.first?.value {
                print("Load profile: \(profileName)")
            }
            
        case .loadprofileandestimate:
            if let profileName = queryItem.queryItems?.first?.value {
                print("Load profile and estimate: \(profileName)")
            }
        }
    } else {
        try deepLinks.thrownoaction()
    }
    
} catch {
    print("Error: \(error.localizedDescription)")
}
```

### Validating Profiles

```swift
let existingProfiles = ["Pictures", "Documents", "default"]
let requestedProfile = "Pictures"

do {
    try deepLinks.validateprofile(requestedProfile, existingProfiles)
    print("Profile exists")
} catch NoValidProfileError.noprofile {
    print("Profile not found")
}
```

### Preventing Concurrent Actions

```swift
var currentQueryItem: DeeplinkQueryItem? = nil

do {
    // Check if another action is already in progress
    try deepLinks.validateNoOngoingURLAction(currentQueryItem)
    
    // Process new action
    currentQueryItem = DeeplinkQueryItem(host: .quicktask, queryItems: nil)
    
} catch OnlyoneURLactionError.onlyoneaction {
    print("Another action is already in progress")
}
```

## Data Types

### Deeplinknavigation Enum

Defines the available deep link actions:

```swift
public enum Deeplinknavigation: String, Sendable {
    case quicktask
    case loadprofile
    case loadprofileandestimate
}
```

### QueryItemNames Enum

Defines valid query parameter names:

```swift
public enum QueryItemNames: String, Sendable {
    case profile
}
```

### DeeplinkQueryItem

Contains the parsed deep link information:

```swift
public struct DeeplinkQueryItem: Hashable, Sendable {
    public let host: Deeplinknavigation
    public let queryItems: [URLQueryItem]?
}
```

## Error Handling

### DeeplinknavigationError

Errors related to URL validation and processing:

- `.invalidurl` - Invalid URL format
- `.invalidscheme` - URL scheme is not "rsyncuiapp"
- `.noaction` - No valid action found in URL

```swift
do {
    try deepLinks.validateURLstring("invalid-url")
} catch DeeplinknavigationError.invalidurl {
    print("Invalid URL")
} catch DeeplinknavigationError.invalidscheme {
    print("Wrong scheme")
} catch DeeplinknavigationError.noaction {
    print("No action defined")
}
```

### NoValidProfileError

Error when a requested profile doesn't exist:

- `.noprofile` - Profile not found in available profiles

```swift
do {
    try deepLinks.validateprofile("NonExistent", existingProfiles)
} catch NoValidProfileError.noprofile {
    print("Profile doesn't exist")
}
```

### OnlyoneURLactionError

Error when attempting to start a new action while one is in progress:

- `.onlyoneaction` - Only one URL action can be active at a time

```swift
do {
    try deepLinks.validateNoOngoingURLAction(currentAction)
} catch OnlyoneURLactionError.onlyoneaction {
    print("Wait for current action to complete")
}
```

## Integration Example

### SwiftUI App Integration

```swift
import SwiftUI

@main
struct MyApp: App {
    let deepLinks = RsyncUIDeepLinks()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    func handleDeepLink(_ url: URL) {
        do {
            guard let components = try deepLinks.validateScheme(url) else {
                return
            }
            
            if let queryItem = deepLinks.handlevalidURL(components) {
                executeAction(queryItem)
            }
        } catch {
            print("Deep link error: \(error.localizedDescription)")
        }
    }
    
    func executeAction(_ queryItem: DeeplinkQueryItem) {
        switch queryItem.host {
        case .quicktask:
            // Handle quick task
            break
        case .loadprofile:
            if let profile = queryItem.queryItems?.first?.value {
                // Load the profile
            }
        case .loadprofileandestimate:
            if let profile = queryItem.queryItems?.first?.value {
                // Load and estimate
            }
        }
    }
}
```

## Requirements

- Swift 5.7+
- macOS 10.15+ / iOS 13.0+

## Thread Safety

All types in this package conform to `Sendable`, making them safe to use across concurrency boundaries.

## License

MIT

## Author

Thomas Evensen
