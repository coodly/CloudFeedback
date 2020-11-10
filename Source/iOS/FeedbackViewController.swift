/*
 * Copyright 2020 Coodly LLC
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

import UIKit
import SwiftUI

public class FeedbackViewController: UIViewController {
    private lazy var viewModel = injected(FeedbackViewModel())
    private lazy var feedbackView = FeedbackView(viewModel: viewModel)
    private lazy var hosting = UIHostingController(rootView: feedbackView)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.pinToSuperviewEdges()
    }
}

private struct FeedbackMessage: Identifiable {
    let id = UUID()
    let message: String
    let fromMe: Bool
}

private typealias Dependencies = StylingConsumer & CloudAvailabilityConsumer

private class FeedbackViewModel: ObservableObject, Dependencies {
    var styling: Styling!
    var cloudAvailable: Bool!
    
    @Published var messages: [FeedbackMessage] = []
    
    @Published var scrolledTo: UUID? = nil
    @Published var message = "LKsl kals klaskd löas"
    
    fileprivate func scrollToLast() {
        scrolledTo = messages.last?.id
    }
    
    fileprivate func send() {
        guard message.hasValue() else {
            return
        }
        
        messages.append(FeedbackMessage(message: message, fromMe: true))
        message = ""
        scrollToLast()
    }
}

private struct FeedbackView: View {
    @ObservedObject var viewModel: FeedbackViewModel
    
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
                .edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView {
                    ScrollViewReader {
                        proxy in
                        
                        FeedbackHeaderView(styling: viewModel.styling)
                        if !viewModel.cloudAvailable {
                            LoginNoticeView(styling: viewModel.styling)
                        }
                        ForEach(viewModel.messages) {
                            message in
                            
                            Bubble(message: message)
                        }
                        .onChange(of: viewModel.scrolledTo) {
                            target in
                            
                            if let target = target {
                                withAnimation {
                                    proxy.scrollTo(target, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                if viewModel.cloudAvailable {
                    MessageEntryView(viewModel: viewModel)
                }
            }
            .lineLimit(nil)
        }
        .onAppear(perform: viewModel.scrollToLast)
    }
}

private struct Bubble: View {
    let message: FeedbackMessage
    
    var body: some View {
        HStack {
            if message.fromMe {
                Spacer(minLength: 20)
            }
            VStack {
                Text(message.message)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(UIColor.systemBackground))
            )
            if !message.fromMe {
                Spacer(minLength: 20)
            }
        }
        .padding(.horizontal)
    }
}

private struct FeedbackHeaderView: View {
    let styling: Styling
    
    var body: some View {
        ZStack {
            Color(styling.mainColor)
                .edgesIgnoringSafeArea([Edge.Set.horizontal, Edge.Set.top])
            VStack {
                Text(styling.greetingTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.largeTitle)
                Text(styling.greetingMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
            }
            .padding()
            .foregroundColor(Color(styling.greetingTextColor))
        }
    }
}

private struct MessageEntryView: View {
    @ObservedObject var viewModel: FeedbackViewModel
    
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
            VStack {
                Button(action: viewModel.send) {
                    ZStack {
                        Circle()
                            .frame(width: 32, height: 32, alignment: .center)
                            .foregroundColor(.white)
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32, alignment: .center)
                            .padding()
                    }
                }
                .foregroundColor(Color(viewModel.styling.mainColor))
            }
        }
        .background(
            Color(UIColor.systemFill)
                .edgesIgnoringSafeArea([Edge.Set.horizontal, Edge.Set.bottom])
        )
    }
}

private struct LoginNoticeView: View {
    let styling: Styling
    
    var body: some View {
        Text(styling.loginNotice)
            .font(.body)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(UIColor.systemBackground))
            )
            .padding(.horizontal)
    }
}
