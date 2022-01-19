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
            
            NavigationView {
                Text("One")
                Text("Two")
                Text("Three")
            }
        }
    }
}
