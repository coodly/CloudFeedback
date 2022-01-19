import CoreData

extension Conversation {
    @NSManaged var platform: String?
    
    @NSManaged var application: Application
    @NSManaged var messages: Set<Message>?
}
