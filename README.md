# MemoryLeakTestKit

![Swift 4.2 compatible](https://img.shields.io/badge/Swift%20version-4.2-green.svg)
![CocoaPods](https://img.shields.io/cocoapods/v/MemoryLeakTestKit.svg)
![Carthage](https://img.shields.io/badge/Carthage-compatible-green.svg)
![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-green.svg)
[![MIT license](https://img.shields.io/badge/lisence-MIT-yellow.svg)](https://github.com/Kuniwak/MemoryLeakTestKit/blob/master/LICENSE)

A testing library to detect memory leaks for Swift.

This library is under development.


## Supported Platforms

| Platform | Build Status |
|:---------|:-------------|
| Linux    | [![CircleCI](https://circleci.com/gh/Kuniwak/MemoryLeakTestKit/tree/master.svg?style=svg)](https://circleci.com/gh/Kuniwak/MemoryLeakTestKit/tree/master) |
| iOS      | [![Build Status](https://app.bitrise.io/app/457e68f44175b9c9/status.svg?token=AHKnQJD43MfDtDeh8-88Nw&branch=master)](https://app.bitrise.io/app/457e68f44175b9c9) |


## Usage

```swift
import MemoryLeakTestKit

let target = createSomething()

let memoryLeaks = detectLeaks(target)
XCTAssertTrue(
    memoryLeaks.leakedObjects.isEmpty,
    memoryLeaks.prettyDescription
)
```


## Example output

```
Summary:
    Found 2 leaked objects

Leaked objects:
    0:
        Description: Node
        Type: Node
        Location: (root).linkedNodes[0]
        Circular Paths: 
            self.linkedNodes[1] === self
    
    1:
        Description: Node
        Type: Node
        Location: (root)
        Circular Paths: 
            self.linkedNodes[0].linkedNodes[0] === self
```


# License

MIT
