import CoreData

extension Message {
    @NSManaged var recordName: String?
    
    @NSManaged var body: String?
    @NSManaged var platform: String?
    @NSManaged var postedAt: Date?
    @NSManaged var sentBy: String?
    
    @NSManaged var conversation: Conversation
}
