🧹 [Refactor openPreferences methods to reduce duplication]

🎯 **What:** The code health issue addressed was the duplication of the methods `openAccessibilityPreferences` and `openAutomationPreferences` in `AppDelegate.swift`.
💡 **Why:** Combining these into a single method `openPreferences(for: String)` improves maintainability and readability by eliminating duplicated logic and creating a reusable pattern for opening other preference panes in the future.
✅ **Verification:** I verified the change by manually inspecting all usages and making sure they correctly supply "Accessibility" or "Automation" as the pane string argument to the new method. Note: The environment does not have macOS build tools like `swift` or `xcodebuild`, so actual compilation couldn't be done, but a static code review confirmed correctness and absence of syntax errors.
✨ **Result:** The codebase is cleaner, shorter, and more DRY (Don't Repeat Yourself), without changing existing behavior.
