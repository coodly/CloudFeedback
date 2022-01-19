import SWLogger

public class Log {
    private static let shared: Log = {
        SWLogger.Log.level = .debug
        SWLogger.Log.add(output: ConsoleOutput())
        
        return Log()
    }()
 
    private let cloud = Logging(name: "Cloud")
    private let db = Logging(name: "DB")
    
    public static let cloud = shared.cloud
    public static let db = shared.db
}
