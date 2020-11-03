import Foundation
//MARK: - AppStore
public enum Store{
    public static let jsonEmpty = """
                        {
                            error:"No data found"
                        }
                    """
    public static let jsonDatum = """
    {
      "Time Series (30min)" : {
        "16:00:00 2018-10-16" :{
            "1. open": "15.4700",
            "2. high": "15.5300",
            "3. low": "15.4500",
            "4. close": "15.5000",
            "5. volume": "1521981"
        },
          "15:30:00 2018-10-16" : {
            "1. open": "15.4600",
            "2. high": "15.4950",
            "3. low": "15.4400",
            "4. close": "15.4700",
            "5. volume": "397948"
            }
        }
    }
    """
}
//MARK: - Models
public struct Stemp {
    let open:String
    let high:String
    let low:String
    let close:String
    let volume:String
}
extension Stemp : Codable{
    enum CodingKeys : String , CodingKey{
        case open = "1. open",
             high = "2. high" ,
             low = "3. low" ,
             close = "4. close",
             volume = "5. volume"
    }
    public init(from decoder: Decoder) throws {
        let sType = String.self
        let container = try decoder.container(keyedBy: CodingKeys.self)
        open = try container.decode(sType, forKey: .open)
        high = try container.decode(sType.self, forKey: .high)
        low = try container.decode(sType.self, forKey: .low)
        close = try container.decode(sType.self, forKey: .close)
        volume = try container.decode(sType.self, forKey: .volume)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(open, forKey: .open)
        try container.encode(high, forKey: .high)
        try container.encode(low, forKey: .low)
        try container.encode(close, forKey: .close)
        try container.encode(volume, forKey: .volume)
    }
}
public struct TimeStemp{
    let stemp : [Date:Stemp]
}
public extension TimeStemp{
    enum CodingKeys : String , CodingKey {
        case stemp, time = "Time Series (30min)", one = "16:00:00 2018-10-16", two = "15:30:00 2018-10-16"
    }
}
extension TimeStemp : Codable{
    public init(from decoder: Decoder) throws {
        var tempStemp:[Date : Stemp] = [:]
        let parent = try! decoder.container(keyedBy: CodingKeys.self)
        guard let child = try? parent.nestedContainer(keyedBy: CodingKeys.self, forKey: .time) else {
            stemp = [:]
            return
        }
        child.allKeys.forEach({ (k) in
            let date = DateFormatter
                .date(DateFormatter.dateFormatter)(from : k.stringValue)
            if let nestedChild = try? child.nestedContainer(keyedBy: Stemp.CodingKeys.self, forKey: k){
                var open = "",high = "",low = "" ,close = "",volume = ""
                nestedChild.allKeys.forEach{
                    if let val = try? nestedChild.decode(String.self, forKey: $0 ){
                        switch $0{
                        case .open:
                            open = val
                        case .high:
                            high = val
                        case .low:
                            low = val
                        case .close:
                            close = val
                        case .volume:
                            volume = val
                        }
                    }
                }
                if let date = date{
                    tempStemp.updateValue(Stemp(open: open, high: high, low: low, close: close, volume: volume), forKey: date)
                }
            }
        })
        self.stemp = tempStemp
    }
    
    public func encode(to encoder: Encoder) throws {
        var parent = encoder.container(keyedBy: CodingKeys.self)
        var child = parent.nestedContainer(keyedBy: CodingKeys.self, forKey: .time)
        try child.encode(stemp[DateFormatter
                                    .date(DateFormatter.dateFormatter)(from : CodingKeys.one.rawValue)!], forKey: .one)
        try child.encode(stemp[DateFormatter
                                    .date(DateFormatter.dateFormatter)(from : CodingKeys.two.rawValue)!], forKey: .two)
    }
}

//MARK: - Utils
public extension DateFormatter{
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss yyyy-MM-dd"
        return formatter
    }()
}
public func handleCache(){
    let targetPath = FileManager.timeStampsFile.path
    if FileManager.default.fileExists(atPath: targetPath){
        if let conData = FileManager.default.contents(atPath: targetPath)?.isEmpty{
            if conData{ writeStringToFile(json) }
        }
    }else{
        writeStringToFile(json)
    }
}
public func writeStringToFile(_ string:String){
    do {
        try string.write(to: FileManager.timeStampsFile, atomically: true, encoding: .utf8)
    } catch {
        try? Store.jsonEmpty.write(to: FileManager.timeStampsFile, atomically: true, encoding: .utf8)
    }
}
//MARK: - Example
let json = Store.jsonDatum
let encoder = JSONEncoder()
let decoder = JSONDecoder()
public func runTest(){
    handleCache()
    let datum = try? Data(contentsOf: FileManager.timeStampsFile)
    if let jsonData = try? decoder.decode(TimeStemp.self, from: datum!) {
        if let datum  = try? encoder.encode(jsonData){
            print(String(data: datum, encoding: .utf8)!)
        }
    }
}
runTest()
