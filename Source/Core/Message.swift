/*
 * Copyright 2017 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Puff
import CloudKit

public struct Message: RemoteRecord {
    public var parent: CKRecordID?
    public var recordData: Data?
    public var recordName: String?
    public static var recordType: String {
        return "Message"
    }
    
    public var body: String?
    var conversation: CKReference?
    public var postedAt: Date?
    public var sentBy: String?
    public var platform: String?
    
    public mutating func loadFields(from record: CKRecord) -> Bool {
        body = record["body"] as? String
        conversation = record["conversation"] as? CKReference
        postedAt = record["postedAt"] as? Date
        sentBy = record["sentBy"] as? String
        platform = record["platform"] as? String
        return true
    }
    
    public init() {
        
    }
}
