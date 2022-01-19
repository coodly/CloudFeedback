import ObjectModel
import SwiftUI
import UIComponents

public struct ConversationsView: View {
    public init() {
        
    }
    public var body: some View {
        List {
            FilteredObjectsListView(predicate: .truePredicate, sort: [NSSortDescriptor(keyPath: \Conversation.modifiedAt, ascending: false)]) {
                (conversation: Conversation) in
                
                VStack(alignment: .leading) {
                    Text(conversation.lastMessage?.body ?? "-")
                    Text(conversation.application.appIdentifier)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}
