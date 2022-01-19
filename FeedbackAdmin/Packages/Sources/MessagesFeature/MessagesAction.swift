import WriteMessageFeature

public enum MessagesAction {
    case respond
    case clearRoute
    
    case writeMessage(WriteMessageAction)
}
