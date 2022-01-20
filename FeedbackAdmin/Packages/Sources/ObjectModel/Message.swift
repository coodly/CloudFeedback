/*
 * Copyright 2022 Coodly LLC
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

public enum PushStatus: String {
    case synced = ""
    case pushNeeded
    case pushFailed
}

extension Message {
    @NSManaged private var internalPushStatus: String
}

public class Message: NSManagedObject {
    public override func willSave() {
        if recordName == nil {
            recordName = UUID().uuidString
        }
    }
    
    public var pushStatus: PushStatus {
        get {
            PushStatus(rawValue: internalPushStatus) ?? .synced
        }
        set {
            internalPushStatus = newValue.rawValue
        }
    }
}
