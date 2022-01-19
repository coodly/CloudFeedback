import CoreData

extension Message {
    @NSManaged var body: String?
    @NSManaged var postedAt: Date?
    @NSManaged var sentBy: String?
    
    @NSManaged var conversation: Conversation
}
