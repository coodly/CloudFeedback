import CoreData

extension Application {
    @NSManaged var appIdentifier: String
    
    @NSManaged var conversations: Set<Conversation>?
}
