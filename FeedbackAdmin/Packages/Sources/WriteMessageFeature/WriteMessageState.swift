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

import ComposableArchitecture
import Extensions
import ObjectModel

public struct WriteMessageState: Equatable {
    @BindableState internal var sentBy = ""
    @BindableState internal var message = ""
    
    internal var sendDisabled = true
    internal let conversation: Conversation
    public init(conversation: Conversation) {
        self.conversation = conversation
    }
    
    internal mutating func checkCanSend() {
        sendDisabled = !(sentBy.hasValue && message.hasValue)
    }
}
