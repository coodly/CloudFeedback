import ComposableArchitecture
import ObjectModel
import SwiftUI
import UIComponents
import WriteMessageFeature

public struct MessagesView: View {
    private let store: Store<MessagesState, MessagesAction>
    public init(store: Store<MessagesState, MessagesAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) {
            viewStore in
            
            List {
                FilteredObjectsListView(predicate: viewStore.messagesPredicate, sort: [NSSortDescriptor(keyPath: \Message.modifiedAt, ascending: true)]) {
                    (message: Message) in
                    
                    Text(message.body ?? "-")
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewStore.send(.respond) }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: { $0.route == .respond },
                    send: MessagesAction.clearRoute
                ),
                content: {
                    NavigationView {
                        IfLetStore(store.scope(state: \.writeMessageState, action: MessagesAction.writeMessage)) {
                            store in
                            
                            WriteMessageView(store: store)
                        }
                        .interactiveDismissDisabled(true)
                    }
                }
            )
        }
    }
}
