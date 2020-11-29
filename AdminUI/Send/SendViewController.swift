/*
 * Copyright 2018 Coodly LLC
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
import AdminCore

private extension Selector {
    static let senderChanged = #selector(SendViewController.senderChanged(_:))
    static let sendMessage = #selector(SendViewController.sendMessage)
}

internal class SendViewController: UIViewController, StoryboardLoaded, UIInjector {
    static var storyboardName: String {
        return "Send"
    }

    @IBOutlet private var sender: UITextField!
    @IBOutlet private var submit: UIButton!
    @IBOutlet private var entryView: UITextView!
    
    private let viewModel = SendViewModel()
    internal var conversation: AdminConversation? {
        didSet {
            viewModel.conversation = conversation
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inject(into: viewModel)
        
        entryView.isScrollEnabled = false
        entryView.text = ""
        
        entryView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        entryView.layer.borderWidth = 1
        entryView.layer.cornerRadius = 5
        entryView.delegate = self
        
        viewModel.callback = {
            [weak self]
            
            status in
            
            self?.sender.text = status.sender
            self?.entryView.text = status.message
            self?.submit.isEnabled = status.sendButtonEnabled
        }
        
        sender.addTarget(self, action: .senderChanged, for: .allEditingEvents)
        sender.delegate = self
        
        submit.addTarget(self, action: .sendMessage, for: .touchUpInside)
    }
    
    @objc fileprivate func senderChanged(_ field: UITextField) {
        viewModel.sender = field.text ?? ""
    }
    
    @objc fileprivate func sendMessage() {
        Log.debug("Send message")
        
        viewModel.submit()
    }
}

extension SendViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.message = textView.text
    }
}

extension SendViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        entryView.becomeFirstResponder()
        return true
    }
}
