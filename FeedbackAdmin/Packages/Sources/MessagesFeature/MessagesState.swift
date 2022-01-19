import Foundation
import ObjectModel

public struct MessagesState: Equatable {
    internal let conversation: Conversation
    
    internal var messagesPredicate: NSPredicate {
        NSPredicate(format: "conversation = %@", conversation)
    }
    
    public init(conversation: Conversation) {
        self.conversation = conversation
    }
}
