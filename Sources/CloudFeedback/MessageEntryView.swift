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

import SwiftUI

internal struct MessageEntryView: View {
    @ObservedObject var viewModel: FeedbackViewModel
    let styling: Styling
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ZStack {
                Text(viewModel.message)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(0)
                    .padding(.all, 8)
                    .padding([.vertical, .leading])
                    .layoutPriority(1)
                TextEditor(text: $viewModel.message)
                    .padding([.vertical, .leading])
            }
            .font(.body)
            VStack {
                Button(action: viewModel.send) {
                    ZStack {
                        Circle()
                            .padding(2)
                            .frame(width: 32, height: 32, alignment: .center)
                            .foregroundColor(.white)
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32, alignment: .center)
                            .padding()
                    }
                }
                .foregroundColor(Color(styling.mainColor))
            }
        }
        .background(
            Color(UIColor.systemFill)
                .edgesIgnoringSafeArea([Edge.Set.horizontal, Edge.Set.bottom])
        )
    }
}

