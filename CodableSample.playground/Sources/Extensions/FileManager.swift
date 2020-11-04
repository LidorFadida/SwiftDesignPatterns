import Foundation

public extension FileManager{
    static var documentDirectoryURL : URL{
        `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    static var timeStampsFile:URL{
        URL(fileURLWithPath: filePath, relativeTo: documentDirectoryURL)
    }
    static let filePath = "TimeStamps.json"
    static let errFilePath = "Error.json"
}
