import Application
import ComposableArchitecture
import ObjectModel
import PersistenceClient
import SwiftUI

@main
struct FeedbackAdminApp: App {
    var body: some Scene {
        WindowGroup {
            ApplicationView(
                store: Store(
                    initialState: ApplicationState(),
                    reducer: applicationReducer,
                    environment: ApplicationEnvironment(
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                        persistenceClient: .client(with: Persistence())
                    )
                )
            )
        }
    }
}
