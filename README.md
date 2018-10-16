# MemoryLeakTestKit

A testing library to detect memory leaks for Swift.

This library is under development.


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
