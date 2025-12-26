# Running Tests

1. In Xcode, select `AppDockTests` or `AppDockUITests` targets.
2. Run the tests from the Test navigator.
3. UI launch tests include a screenshot baseline in `UITestsLaunchTests`.
4. For unit tests, keep logic isolated and use lightweight mocks (see `AppDockTests/RecentAppsController.swift`).
