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

internal class SendViewController: UIViewController, StoryboardLoaded {
    static var storyboardName: String {
        return "Send"
    }

    @IBOutlet private var sender: UITextField!
    @IBOutlet private var submit: UIButton!
    @IBOutlet private var entryView: UITextView!
    
    private let viewModel = SendViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        entryView.isScrollEnabled = false
        entryView.text = ""
        
        entryView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        entryView.layer.borderWidth = 1
        entryView.layer.cornerRadius = 5
        
        viewModel.callback = {
            [weak self]
            
            status in
            
            self?.sender.text = status.sender
            self?.entryView.text = status.message
            self?.submit.isEnabled = status.sendButtonEnabled
        }
    }
}
