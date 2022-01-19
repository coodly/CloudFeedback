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
