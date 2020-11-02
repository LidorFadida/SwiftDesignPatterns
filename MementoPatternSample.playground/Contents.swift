//  MementoPatternSample.playground
//
//  Created by Lidor Fadida on 2/10/2020.
//
import Foundation

//MARK: - Behavior
protocol ManageAble{
    func handleBreak(_ shouldHe:Bool)
    func updateDailySalesAmount(amount of:Int)
    func advanceClockTime(_ byHour:Int)
}
//MARK: - Originator
public class Employee:Codable , ManageAble{
    public class State : Codable{
        public var id:Int?
        public var onBreak = false
        public var clockedTime = 0
        public var todaysSales = 0
    }
    var state = State()
    
    init(){ state.id = UUID.init().hashValue }
    
    func handleBreak(_ shouldHe:Bool){
        state.onBreak = shouldHe
    }
    func updateDailySalesAmount(amount of:Int){
        state.todaysSales += of
    }
    func advanceClockTime(_ byHour: Int) {
        state.clockedTime += byHour
    }
}

//MARK: - CareTaker
public class ShiftSystem{
    static let shared = ShiftSystem()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let userDefaults = UserDefaults.standard
    var dailyEmployeeList:Set<Int>{
        get{ userDefaults.employees(.savingList) }
        set{ userDefaults.setValue(newValue, forKey:.savingList) }
    }
    private init(){ }
    public func save(_ emp:Employee) throws {
        dailyEmployeeList.insert(emp.state.id!)
        let data = try encoder.encode(emp)
        userDefaults.setValue(data, forKey: String(emp.state.id!))
    }
    
    public func load(empUUID:Int) throws -> Employee{
        guard let data = userDefaults.data(forKey: String(empUUID)) ,
              let emp  = try? decoder.decode(Employee.self, from: data) else{
            throw Error.employeeNotFound
        }
        return emp
    }
}
//MARK: - Errors
public enum Error : String, Swift.Error{
    case employeeNotFound
}

//MARK: - Extensions
extension UserDefaults{
    func setValue<T : Any>(_ value:Set<T>, forKey:SavingKeys){
        setValue(Array(value), forKey: forKey.rawValue)
    }
    enum SavingKeys: String{
        case savingList = "savingsList"
    }
    func employees(_ key:SavingKeys) -> Set<Int>{
        if let history = array(forKey: key.rawValue) as? [Int]{
            return Set(history)
        }
        return Set<Int>()
    }
    func clearCache(){
        dictionaryRepresentation().keys.forEach { removeObject(forKey: $0) }
    }
}
//MARK: - Example
/// Creating employee
var employee = Employee()
/// Creating a shiftManagement system
let shiftSystem = ShiftSystem.shared
/// Updating State
employee.updateDailySalesAmount(amount: 20)
/// Saving
try shiftSystem.save(employee)
/// Loading the first employee as an exmple
if let emp = shiftSystem.dailyEmployeeList.first{ employee = try! shiftSystem.load(empUUID: emp) }
print("\(employee.state.todaysSales)")
print(shiftSystem.dailyEmployeeList)
//MARK: - Reset Defaults
//var u = UserDefaults.standard
//u.clearCache()

