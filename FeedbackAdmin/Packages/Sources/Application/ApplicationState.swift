import Logging

public struct ApplicationState: Equatable {
    internal var persistenceLoaded = false
    
    public init() {
        Log.app.debug("Start the logs :)")
    }
}
