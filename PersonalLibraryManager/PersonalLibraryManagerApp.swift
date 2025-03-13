import SwiftUI

@main
struct PersonalLibraryManagerApp: App {
    @StateObject private var libraryData = LibraryData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(libraryData)
        }
    }
}
