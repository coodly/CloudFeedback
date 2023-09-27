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

import Application
import CloudClient
import CloudClientLive
import CloudKit
import ComposableArchitecture
import Dependencies
import ObjectModel
import PersistenceClient
import SwiftUI

@main
struct FeedbackAdminApp: App {
    private let persistence = Persistence()
    
    var body: some Scene {
        WindowGroup {
            ApplicationView(
                store: Store(
                    initialState: ApplicationState(),
                    reducer: applicationReducer,
                    environment: ApplicationEnvironment(
                        cloudClient: .client(with: CKContainer(identifier: "iCloud.com.coodly.feedback")),
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                        persistenceClient: .client(with: persistence)
                    )
                )
            )
            .environment(\.managedObjectContext, persistence.viewContext)
        }
    }
}

extension CloudClient: DependencyKey {
    public static var liveValue: CloudClient {
        .client(with: CKContainer(identifier: "iCloud.com.coodly.feedback"))
    }
}
