import CloudKit

public struct CloudClient {
    private let container: CKContainer
}

extension CloudClient {
    public static func client(with contrainer: CKContainer) -> CloudClient {
        CloudClient(
            container: contrainer
        )
    }
}
