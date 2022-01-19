import ComposableArchitecture
import SwiftUI

public struct ApplicationView: View {
    private let store: Store<ApplicationState, ApplicationAction>
    public init(store: Store<ApplicationState, ApplicationAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) {
            viewStore in
            
            if viewStore.persistenceLoaded {
                NavigationView {
                    Text("One")
                    Text("Two")
                    Text("Three")
                }
            } else {
                ProgressView()
                    .progressViewStyle(.automatic)
                    .onAppear(perform: { viewStore.send(.loadPersistence) })
            }
        }
    }
}
