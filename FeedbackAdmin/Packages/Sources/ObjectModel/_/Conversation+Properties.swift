import CoreData

extension Conversation {
    @NSManaged var recordName: String?
        
    @NSManaged var application: Application
    @NSManaged var messages: Set<Message>?
}
