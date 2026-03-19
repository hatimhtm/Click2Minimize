import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isClickToMinimizeEnabled: Bool = {
        if UserDefaults.standard.object(forKey: "ClickToMinimizeEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "ClickToMinimizeEnabled") // Set default value
            return true
        }
        return UserDefaults.standard.bool(forKey: "ClickToMinimizeEnabled")
    }()
    
    var body: some View {
        VStack(spacing: 2) {
            Toggle("Enable Click2Minimize", isOn: $isClickToMinimizeEnabled)
                .padding()
                // .toggleStyle(SwitchToggleStyle(tint: .blue)) // this breaks intel mac
                .onChange(of: isClickToMinimizeEnabled) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "ClickToMinimizeEnabled")
                    NotificationCenter.default.post(name: NSNotification.Name("ClickToHideStateChanged"), object: newValue)
                }

            Text("*If the app doesn't work as expected, please ensure that accessibility and automation permissions are enabled via app's menubar menu.")
                .font(.footnote)
                .padding(15)   
                .foregroundColor(.orange) // Optional: Change color to red for emphasis
                .multilineTextAlignment(.center) 
        }
        .frame(width: 240, height: 150)

    }
}

