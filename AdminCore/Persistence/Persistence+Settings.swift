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
import CoreDataPersistence

internal extension Setting {
    enum Key: String {
        case lastConversationsCheckTime
    }
}

internal extension NSManagedObjectContext {
    internal var lastConversationsCheckTime: Date {
        get {
            return date(for: .lastConversationsCheckTime)
        }
        set {
            set(date: newValue, for: .lastConversationsCheckTime)
        }
    }
}

private extension NSManagedObjectContext {
    private func date(for key: Setting.Key, fallback: Date = Date.distantPast) -> Date {
        return setting(for: key)?.dateValue ?? fallback
    }
    
    private func set(date: Date, for key: Setting.Key) {
        let saved: Setting = setting(for: key) ?? insertEntity()
        saved.key = key
        saved.dateValue = date
    }
    
    private func setting(for key: Setting.Key) -> Setting? {
        return fetchEntity(where: "internalKey", hasValue: key.rawValue)
    }
}
