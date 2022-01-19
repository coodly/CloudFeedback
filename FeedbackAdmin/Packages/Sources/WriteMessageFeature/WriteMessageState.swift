import ComposableArchitecture

public struct WriteMessageState: Equatable {
    @BindableState internal var sentBy = ""
    @BindableState internal var message = ""
    
    internal var sendDisabled = true
    
    public init() {
        
    }
    
    internal mutating func checkCanSend() {
        sendDisabled = !(sentBy.hasValue && message.hasValue)
    }
}

extension String {
    fileprivate var hasValue: Bool {
        !trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }
}
