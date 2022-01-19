import Foundation
import ObjectModel
import WriteMessageFeature

public struct MessagesState: Equatable {
    enum Route: Equatable {
        case respond
    }

    internal var route: Route?
    
    internal let conversation: Conversation
    
    internal var messagesPredicate: NSPredicate {
        NSPredicate(format: "conversation = %@", conversation)
    }
    
    internal var writeMessageState: WriteMessageState?
    
    public init(conversation: Conversation) {
        self.conversation = conversation
    }
}
