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

private extension DateFormatter {
    static let settings: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

private extension Setting {
    @NSManaged var internalKey: String
}

internal class Setting: NSManagedObject {
    internal var key: Setting.Key {
        get {
            return Setting.Key(rawValue: internalKey)!
        }
        set {
            internalKey = newValue.rawValue
        }
    }
    
    internal var dateValue: Date? {
        get {
            guard let value = self.value else {
                return nil
            }
            
            return DateFormatter.settings.date(from: value)
        }
        set {
            guard let date = newValue else {
                value = nil
                return
            }
            value = DateFormatter.settings.string(from: date)
        }
    }
}
