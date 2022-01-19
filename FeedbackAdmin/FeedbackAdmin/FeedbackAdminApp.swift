import Application
import ComposableArchitecture
import SwiftUI

@main
struct FeedbackAdminApp: App {
    var body: some Scene {
        WindowGroup {
            ApplicationView(
                store: Store(
                    initialState: ApplicationState(),
                    reducer: applicationReducer,
                    environment: ApplicationEnvironment()
                )
            )
        }
    }
}
