import ObjectModel
import SwiftUI
import UIComponents

public struct MessagesView: View {
    public init() {
        
    }
    public var body: some View {
        List {
            FilteredObjectsListView(predicate: .truePredicate, sort: [NSSortDescriptor(keyPath: \Message.modifiedAt, ascending: false)]) {
                (message: Message) in
                
                Text(message.body ?? "-")
            }
        }
    }
}
