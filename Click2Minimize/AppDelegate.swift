import Cocoa
import CoreGraphics
import SwiftUI
import ApplicationServices
import Combine
import ServiceManagement
import Foundation
import os.log

private let log = Logger(subsystem: "com.idemfactor.Click2Minimize", category: "app")

/// Dock items we never act on — these have no useful "active windows" semantic.
private let ignoredDockItems: Set<String> = ["Launchpad", "Trash", "Downloads"]

@main // This indicates that this is the entry point of the application
struct Click2MinimizeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Click2Minimize", image: "MenuBarIcon") {
            Button(action: appDelegate.openPopupWindow, label: { Text("Settings") })
            Divider()
            
            // New button to open System Preferences for Accessibility
            Button(action: appDelegate.openAccessibilityPreferences, label: { Text("Accessibility Preferences") })

            // New button to open System Preferences for Automation
            Button(action: appDelegate.openAutomationPreferences, label: { Text("Automation Preferences") })
            Divider()

            Button(action: appDelegate.quitApp, label: { Text("Quit") })
        }
    }

    init() {
        // Retrieve the current version and build number from Info.plist
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            appDelegate.currentVersion = "\(version).\(build)" // Combine version and build number
        }
        appDelegate.checkForUpdates()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var eventTap: CFMachPort?
    var mainWindow: NSWindow?
    var cancellables = Set<AnyCancellable>()
    var dockItems: [DockItem] = [] // Global variable to hold dock item rectangles
    private var isClickToMinimizeEnabled: Bool = {
        if UserDefaults.standard.object(forKey: "ClickToMinimizeEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "ClickToMinimizeEnabled")
            return true
        }
        return UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
    }()
    var appDict: [String: String] = [:]
    var currentVersion: String = ""
    private var dockUpdateTask: DispatchWorkItem?
     
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    func openSettingsWindow() {
        if let window = mainWindow {
            window.makeKeyAndOrderFront(nil)
        } else {
            let contentView = ContentView()
            let hostingController = NSHostingController(rootView: contentView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "Version \(currentVersion)"
            window.styleMask = [.titled, .closable]
            window.center()
            window.makeKeyAndOrderFront(nil)
            self.mainWindow = window
        }
    }
    
    @objc func openPopupWindow() {
        openSettingsWindow()
        if let w = self.mainWindow {
            w.level = .floating // make it stay on top of others
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Check for accessibility permissions
        if !isAccessibilityEnabled() {
            promptForAccessibilityPermission()
        }

        // Set the application to be an accessory application
        NSApplication.shared.setActivationPolicy(.accessory)

        // Register for ClickToHideStateChanged notifications
        NotificationCenter.default.addObserver(self, selector: #selector(updateClickToHideState(_:)), name: NSNotification.Name("ClickToHideStateChanged"), object: nil)

        // Start observing Dock changes.
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(self, selector: #selector(dockChanged), name: NSWorkspace.didLaunchApplicationNotification, object: nil)
        center.addObserver(self, selector: #selector(dockChanged), name: NSWorkspace.didActivateApplicationNotification, object: nil)
        center.addObserver(self, selector: #selector(dockChanged), name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        center.addObserver(self, selector: #selector(dockChanged), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)

        if launchAtLoginEnabled {
            registerLoginItem()
        }
        setupAppDict()
        setupEventTap()

        log.info("Click2Minimize launched")
        updateDockItems()
    }

    /// Whether the user has opted in to launch-at-login. Default: false.
    /// Was unconditionally enabled in older builds; respect existing state.
    var launchAtLoginEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: "LaunchAtLoginEnabled") == nil { return false }
            return UserDefaults.standard.bool(forKey: "LaunchAtLoginEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LaunchAtLoginEnabled")
            do {
                if newValue {
                    if SMAppService.mainApp.status != .enabled { try SMAppService.mainApp.register() }
                } else {
                    if SMAppService.mainApp.status == .enabled { try SMAppService.mainApp.unregister() }
                }
            } catch {
                log.error("launch-at-login toggle failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    @objc func dockChanged(notification: Notification) {
        // Update dock items whenever a relevant event occurs
        updateDockItems()
    }

    @objc func updateDockItems() {
        // Trailing-edge debounce: coalesce bursts of dock-changed events
        // (launch / activate / space change all fire together) into a single
        // AppleScript query.
        dockUpdateTask?.cancel()
        let task = DispatchWorkItem { [weak self] in self?.performDockUpdate() }
        dockUpdateTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }

    private func performDockUpdate() {
        getDockRects().sink { [weak self] dockItems in
            self?.dockItems = dockItems ?? []
        }.store(in: &cancellables)
        log.debug("dock items refreshed")
    }

    func setupAppDict() {
        appDict["Visual Studio Code"] = "Code"
        appDict["Rosetta Stone Learn Languages"] = "Rosetta Stone"
    }
    
    func setupEventTap() {
        let eventMask: CGEventMask = (1 << CGEventType.leftMouseDown.rawValue) // Capture only left mouse clicks
        
        // Create the event tap
        guard let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .tailAppendEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                // Retrieve the AppDelegate from refcon
                let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon!).takeUnretainedValue()
                return AppDelegate.eventTapCallback(proxy: proxy, type: type, event: event, appDelegate: appDelegate)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque() // Pass the AppDelegate as userInfo
        ) else {
            log.error("failed to create event tap — accessibility permission missing?")
            return
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)

        self.eventTap = eventTap
        log.info("event tap installed")
    }

    static func eventTapCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent?, appDelegate: AppDelegate) -> Unmanaged<CGEvent>? {
        guard let event = event else { return nil }

        // Pass-through if disabled or the frontmost app is fullscreen.
        if !appDelegate.isClickToMinimizeEnabled || appDelegate.isFrontmostAppFullscreen() {
            return Unmanaged.passUnretained(event)
        }

        let mouseLocation = event.location

        guard let dockItem = appDelegate.dockItems.first(where: { $0.rect.contains(mouseLocation) }) else {
            return Unmanaged.passUnretained(event)
        }

        if ignoredDockItems.contains(dockItem.appID) {
            return Unmanaged.passUnretained(event)
        }

        let runningApps = NSWorkspace.shared.runningApplications
        guard let app = runningApps.first(where: {
            $0.localizedName == dockItem.appID || $0.localizedName == appDelegate.appDict[dockItem.appID]
        }) else {
            log.debug("no running application matched dock item: \(dockItem.appID, privacy: .public)")
            return Unmanaged.passUnretained(event)
        }

        // Only minimize when the user clicks the dock icon of the already-active app
        // (matching the Windows-taskbar behaviour). Otherwise let the default click through.
        guard app.isActive && !app.isHidden else {
            return Unmanaged.passUnretained(event)
        }

        let minimized = AppDelegate.minimizeAppWindows(for: app)
        if minimized {
            log.debug("minimized windows for: \(app.localizedName ?? "Unknown", privacy: .public)")
            return nil
        }
        return Unmanaged.passUnretained(event)
    }

    static func minimizeAppWindows(for app: NSRunningApplication) -> Bool {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)
        
        guard result == .success, let windows = windowsRef as? [AXUIElement] else {
            return false
        }
        
        var minimizedAny = false
        for window in windows {
            var minimizedRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimizedRef) == .success,
               let isMinimized = minimizedRef as? Bool, isMinimized == false {
                
                let setStatus = AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, true as CFTypeRef)
                if setStatus == .success {
                    minimizedAny = true
                }
            }
        }
        return minimizedAny
    }

    /// True if the frontmost (non-Click2Minimize) app has at least one fullscreen window.
    /// We don't want to click-minimize a fullscreen window — that interrupts the user.
    private func isFrontmostAppFullscreen() -> Bool {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return false }
        let element = AXUIElementCreateApplication(frontApp.processIdentifier)

        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXWindowsAttribute as CFString, &windowsRef) == .success,
              let windows = windowsRef as? [AXUIElement] else {
            return false
        }

        for window in windows {
            var fullscreenRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(window, "AXFullScreen" as CFString, &fullscreenRef) == .success,
               let isFullscreen = fullscreenRef as? Bool, isFullscreen {
                return true
            }
        }
        return false
    }

    // Define a struct to hold the dock item information
    struct DockItem {
        let rect: NSRect
        let appID: String
    }

    func getDockRects() -> Future<[DockItem]?, Never> {
        return Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                var dockItems: [DockItem] = []
                
                let script = """
                tell application "System Events"
                    set dockItemList to {}
                    tell process "Dock"
                        set dockItems to every UI element of list 1
                        repeat with dockItem in dockItems
                            set dockPosition to position of dockItem
                            set dockSize to size of dockItem
                            set appID to name of dockItem -- Get the application name
                            set end of dockItemList to {dockPosition, dockSize, appID}
                        end repeat
                        return dockItemList
                    end tell
                end tell
                """
                
                var error: NSDictionary?
                if let appleScript = NSAppleScript(source: script) {
                    let result = appleScript.executeAndReturnError(&error)
                    if let error = error {
                        log.error("AppleScript error: \(String(describing: error), privacy: .public)")
                        promise(.success(nil))
                        return
                    }
                    
                    let parsedItems = self.parseDockItems(from: result)
                    dockItems.append(contentsOf: parsedItems)
                }
                
                promise(.success(dockItems))
            }
        }
    }

    private func parseDockItems(from descriptor: NSAppleEventDescriptor) -> [DockItem] {
        var items: [DockItem] = []

        guard descriptor.descriptorType == typeAEList else {
            return items
        }

        for index in 1...descriptor.numberOfItems {
            guard let item = descriptor.atIndex(index),
                  let positionDescriptor = item.atIndex(1),
                  let sizeDescriptor = item.atIndex(2),
                  let appIDDescriptor = item.atIndex(3) else { continue }

            // Extract position values
            let positionX = positionDescriptor.atIndex(1)?.doubleValue ?? 0
            let positionY = positionDescriptor.atIndex(2)?.doubleValue ?? 0

            // Extract size values
            let sizeWidth = sizeDescriptor.atIndex(1)?.doubleValue ?? 0
            let sizeHeight = sizeDescriptor.atIndex(2)?.doubleValue ?? 0

            // Extract app ID (name)
            let appID = appIDDescriptor.stringValue ?? "Unknown"

            let rect = NSRect(x: positionX, y: positionY, width: sizeWidth, height: sizeHeight)
            items.append(DockItem(rect: rect, appID: appID))
        }

        return items
    }

    func registerLoginItem() {
        do {
            if SMAppService.mainApp.status != .enabled {
                try SMAppService.mainApp.register()
            }
        } catch {
            log.error("registerLoginItem: \(error.localizedDescription, privacy: .public)")
        }
    }

    @objc func updateClickToHideState(_ notification: Notification) {
        if let enabled = notification.object as? Bool {
            isClickToMinimizeEnabled = enabled
            // Save the new state to UserDefaults
            UserDefaults.standard.set(enabled, forKey: "ClickToMinimizeEnabled")
        }
    }

    func isAccessibilityEnabled() -> Bool {
        return AXIsProcessTrusted()
    }

    func promptForAccessibilityPermission() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = 
        """
        To allow Click2Minimize to control the system dock, please enable accessibility permissions for it in System Preferences.
        
        Please relaunch app after permission granted.
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Preferences")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openAccessibilityPreferences()
            // Quit the application as it won't work without permission
            // Delay termination by 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    func openAccessibilityPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    func openAutomationPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!
        NSWorkspace.shared.open(url)
    }

    func checkForUpdates() {
        let url = URL(string: "https://api.github.com/repos/hatimhtm/Click2Minimize/releases/latest")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                log.error("checkForUpdates: \(error?.localizedDescription ?? "unknown error", privacy: .public)")
                return
            }
            if let releaseInfo = try? JSONDecoder().decode(Release.self, from: data) {
                // Compare with current version and prompt user if an update is available
                if self.isNewerVersion(releaseInfo.tag_name, currentVersion: self.currentVersion) {
                    DispatchQueue.main.async {
                        self.promptUserToUpdate(releaseInfo)
                    }
                }
            }
        }
        task.resume()
    }

    private func isNewerVersion(_ newVersion: String, currentVersion: String) -> Bool {
        let newVersionComponents = newVersion.split(separator: ".").map { Int($0) ?? 0 }
        let currentVersionComponents = currentVersion.split(separator: ".").map { Int($0) ?? 0 }

        for (new, current) in zip(newVersionComponents, currentVersionComponents) {
            if new > current {
                return true
            } else if new < current {
                return false
            }
        }
        return newVersionComponents.count > currentVersionComponents.count
    }

    private func promptUserToUpdate(_ releaseInfo: Release) {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = "A new version \(releaseInfo.tag_name) is available. Would you like to update?"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Update")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Fetch the latest DMG URL from the release info
            fetchLatestDMG(releaseInfo: releaseInfo)
        }
    }

    private func fetchLatestDMG(releaseInfo: Release) {
        let url = URL(string: "https://api.github.com/repos/hatimhtm/Click2Minimize/releases/latest")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                log.error("fetchLatestDMG: \(error?.localizedDescription ?? "unknown error", privacy: .public)")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let assets = json["assets"] as? [[String: Any]] {
                for asset in assets {
                    if let downloadURL = asset["browser_download_url"] as? String,
                       let name = asset["name"] as? String,
                       name.hasSuffix(".dmg") {
                        self.downloadDMG(from: downloadURL)
                        break
                    }
                }
            }
        }
        task.resume()
    }

    private func downloadDMG(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard let localURL = localURL, error == nil else {
                log.error("downloadDMG: \(error?.localizedDescription ?? "unknown error", privacy: .public)")
                self.openBrowserForManualUpgrade()
                return
            }

            let mountTask = Process()
            mountTask.launchPath = "/usr/bin/hdiutil"
            mountTask.arguments = ["attach", localURL.path]

            mountTask.terminationHandler = { process in
                if process.terminationStatus == 0 {
                    let mountedVolumePath = "/Volumes/Click2Minimize"
                    let appDestinationURL = URL(fileURLWithPath: "/Applications/Click2Minimize.app")

                    do {
                        let appSourceURL = URL(fileURLWithPath: "\(mountedVolumePath)/Click2Minimize.app")
                        if FileManager.default.fileExists(atPath: appDestinationURL.path) {
                            try FileManager.default.removeItem(at: appDestinationURL)
                        }
                        try FileManager.default.copyItem(at: appSourceURL, to: appDestinationURL)
                        log.info("installed Click2Minimize to /Applications")

                        DispatchQueue.main.async { self.promptUserToRelaunch() }
                    } catch {
                        log.error("copy to /Applications failed: \(error.localizedDescription, privacy: .public)")
                        self.openBrowserForManualUpgrade()
                    }

                    let unmountTask = Process()
                    unmountTask.launchPath = "/usr/bin/hdiutil"
                    unmountTask.arguments = ["detach", mountedVolumePath]
                    unmountTask.launch()
                    unmountTask.waitUntilExit()
                } else {
                    log.error("failed to mount DMG")
                    self.openBrowserForManualUpgrade()
                }
            }

            mountTask.launch()
        }
        task.resume()
    }

    private func openBrowserForManualUpgrade() {
        if let url = URL(string: "https://github.com/hatimhtm/Click2Minimize/releases") {
            NSWorkspace.shared.open(url)
        }
    }

    private func promptUserToRelaunch() {
        let alert = NSAlert()
        alert.messageText = "Update Successful"
        alert.informativeText = "The application has been successfully updated."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Relaunch")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let appURL = URL(fileURLWithPath: "/Applications/Click2Minimize.app")
            NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSApplication.shared.terminate(nil)
        }
    }

    struct Release: Codable {
        let tag_name: String
    }
}
