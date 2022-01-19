import SWLogger

public class Log {
    private static let shared: Log = {
        SWLogger.Log.level = .debug
        SWLogger.Log.add(output: ConsoleOutput())
        
        return Log()
    }()
 
    private lazy var db = Logging(name: "DB")
    
    public static let db = shared.db
}
