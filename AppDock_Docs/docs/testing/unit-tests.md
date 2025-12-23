# Unit Tests

## Creating a New Unit Test File

1. In Xcode, `File > New > File...` and choose **Unit Test Case Class**.
2. Set the target to `AppDockTests`.
3. Name the file (for example, `DockViewLogicTests.swift`).
4. Import your module with `@testable import AppDock`.
5. Prefer logic-only tests that avoid UI where possible; use lightweight stubs or helpers.

Example skeleton:

```swift
import XCTest
@testable import AppDock

final class DockViewLogicTests: XCTestCase {
    func testExample() {
        // Arrange
        // Act
        // Assert
    }
}
```
