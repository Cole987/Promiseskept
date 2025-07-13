import SwiftUI

@main
struct PromisTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.viewModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let viewModel = PromiseViewModel()
    
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        // gestion quick actions ici
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // setup quick actions ici
    }
}
