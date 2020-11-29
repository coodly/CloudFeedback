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

import CoreData

extension Message {
    @NSManaged var recordName: String
    @NSManaged var recordData: Data?
    
    @NSManaged public var body: String
    @NSManaged public var postedAt: Date
    @NSManaged public var sentBy: String?
    @NSManaged public var platform: String?

    @NSManaged var conversation: AdminConversation
    @NSManaged var syncStatus: SyncStatus?
}
