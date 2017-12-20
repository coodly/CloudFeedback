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

import Foundation
import SWLogger
import CoreDataPersistence
import CloudFeedback

public class CoreLog {
    public static func enableLogging() {
        SWLogger.Log.add(output: FileOutput())
        SWLogger.Log.add(output: ConsoleOutput())
        
        SWLogger.Log.logLevel = .debug
        
        CoreDataPersistence.Logging.set(logger: PersistenceLogger())
        CloudFeedback.Logging.set(logger: FeedbackLogger())
    }
    
    public static func debug<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        SWLogger.Log.debug(object, file: file, function: function, line: line)
    }
}

internal class Log {
    public static func debug<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        CoreLog.debug(object, file: file, function: function, line: line)
    }
}

private class PersistenceLogger: CoreDataPersistence.Logger {
    func log<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        CoreLog.debug(object, file: file, function: function, line: line)
    }
}

private class FeedbackLogger: CloudFeedback.Logger {
    func log<T>(_ object: T, file: String = #file, function: String = #function, line: Int = #line) {
        CoreLog.debug(object, file: file, function: function, line: line)
    }
}
