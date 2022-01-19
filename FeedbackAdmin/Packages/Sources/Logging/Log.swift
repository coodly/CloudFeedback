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

import SWLogger

public class Log {
    private static let shared: Log = {
        SWLogger.Log.level = .debug
        SWLogger.Log.add(output: ConsoleOutput())
        
        return Log()
    }()
 
    private let app = Logging(name: "App")
    
    public static let app = shared.app
    public static let cloud = Logging(name: "Cloud")
    public static let db = Logging(name: "DB")
}
