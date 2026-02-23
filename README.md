<div align="center">
  <img src="https://img.shields.io/badge/Click2Minimize-Window%20Management-FA7343?style=for-the-badge&logo=apple&logoColor=white" alt="Click2Minimize">
  
  <h1>🖱️ Click2Minimize</h1>
  <p><strong>A seamless enhancement to native macOS window management</strong></p>
  <p>A sleek, highly-polished accessibility utility designed to refine the dock interaction experience on macOS. This application modifies standard system behavior, allowing users to minimize windows simply by clicking their application icon in the Dock—a quality-of-life improvement heavily requested by power users.</p>
  <br>

  ![Swift](https://img.shields.io/badge/Swift-5.0-FA7343?logo=swift&logoColor=white)
  ![macOS](https://img.shields.io/badge/macOS-13.0+-000000?logo=apple&logoColor=white)
  ![Xcode](https://img.shields.io/badge/Xcode-15-147EFB?logo=xcode&logoColor=white)
  ![License](https://img.shields.io/badge/License-MIT-green)
  
  <br>
  
  > 🚧 **Work In Progress**: I am actively working on making Click2Minimize better day after day. Expect frequent updates and improvements!
</div>

---

## 🎨 Design Philosophy

This project brings an elegant and native-feeling window management feature to macOS, focusing on zero-friction interactions.
-   **Native Integration:** Operates entirely in the background using minimal system resources.
-   **Accessibility Driven:** Utilizes powerful `AXUIElement` permissions to securely interact with the macOS Window Server.
-   **Cross-platform Support:** Equipped with an AppleScript fallback to handle modern Mac Catalyst and Electron applications perfectly.

## 🛠️ Tech Stack

| Category | Technologies |
|----------|--------------|
| **Core** | Swift 5.0, AppleScript |
| **Frameworks** | Cocoa, ApplicationServices, Combine |
| **Tooling** | Xcode 15 |
| **OS Target** | macOS 13.0+ |

## 🚀 Features

-   **Dock Minimization:** Click any active application's icon in the Dock to smoothly minimize all its visible windows.
-   **Smart Un-Minimize:** Naturally integrates with the default macOS behavior to un-minimize windows upon the next click.
-   **Universal Compatibility:** Gracefully handles stubborn cross-platform applications with robust fallback engines.
-   **Auto-Updater Disabled:** Removed external dependencies to ensure a stable, offline, and reliable local build.

---

## 📦 Installation

To install Click2Minimize directly on your Mac:

1.  **Download the latest Release**
    Grab the `.dmg` file from the [Releases page](../../releases/latest).

2.  **Install the App**
    Drag the app into your `/Applications` folder.

3.  **Grant Permissions**
    When launched, the app will request Accessibility Permissions. Open System Settings > Privacy & Security > Accessibility and toggle it on.

---

## 💻 Build from Source

To compile the application locally:

```bash
git clone https://github.com/hatimhtm/Click2Minimize.git
cd Click2Minimize

# Build the release binary
xcodebuild -scheme "Click2Hide" -configuration Release -derivedDataPath build

# Package it into a DMG
./build_dmg.sh
```

---

## 🤝 Let's Connect

<div align="center">
  <p><sub>Built with ❤️ for power users everywhere</sub></p>
  
  [![Portfolio](https://img.shields.io/badge/Portfolio-hatimelhassak.is--a.dev-000000?style=flat-square&logo=vercel&logoColor=white)](https://hatimelhassak.is-a.dev)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-Hatim%20El%20Hassak-0077B5?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/hatim-elhassak/)
  [![Email](https://img.shields.io/badge/Email-hatimelhassak.official@gmail.com-D14836?style=flat-square&logo=gmail&logoColor=white)](mailto:hatimelhassak.official@gmail.com)
  [![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=flat-square&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/hatimelhassak)
</div>
