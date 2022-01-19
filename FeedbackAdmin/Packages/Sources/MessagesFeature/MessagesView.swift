import ComposableArchitecture
import ObjectModel
import SwiftUI
import UIComponents

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
        }
    }
}
