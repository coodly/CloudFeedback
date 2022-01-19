import ComposableArchitecture
import SwiftUI

public struct WriteMessageView: View {
    private let store: Store<WriteMessageState, WriteMessageAction>
    
    public init(store: Store<WriteMessageState, WriteMessageAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) {
            viewStore in
         
            Text("Cake")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Image(systemName: "paperplane")
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: { viewStore.send(.cancel) }) {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}
