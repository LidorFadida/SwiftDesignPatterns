import Foundation
//MARK: - Models
public struct CreditCard{
    let cardNumber:String
    let cardCode:Int
    let cardType:CardType
    let paymentMethod:PaymentMethod
    var paymentStrategy:PaymentStrategy{
        switch cardType {
        case .visa:
            return VisaStrategy()
        case .masterCard:
            return MasterCardStrategy()
        }
    }
}
extension CreditCard : CustomStringConvertible{
    public var description: String{
        return "Card Number : \(cardNumber) || CardCode : \(cardCode) || CardType : \(cardType) || Payment Method : \(paymentMethod)"
    }
}

public enum CardType{
    case visa,
         masterCard
}

public enum PaymentMethod{
    case fastTransfer,
         credit
}
//MARK: - Builder
public class CreditCardBuilder{
    public private(set) var cardNumber:String = ""
    public private(set) var cardCode:Int = 0
    public private(set) var cardType:CardType = .visa
    public private(set) var paymentMethod:PaymentMethod = .fastTransfer
    
    public func setCardType(_ type:CardType){
        self.cardType = type
    }
    public func setPaymentMethod(_ method:PaymentMethod){
        self.paymentMethod = method
    }
    public func setCardNumber(_ cardNumber:String){
        self.cardNumber = cardNumber
    }
    public func setCardCode(_ code:Int){
        self.cardCode = code
    }
    public func build() throws -> CreditCard{
        if cardNumber.isEmpty || cardCode == 0 || cardCode < 0{
            throw Error.paymentCannotBeProccesed
        }
        return CreditCard(cardNumber: cardNumber, cardCode: cardCode, cardType: cardType , paymentMethod: paymentMethod)
    }
}
//MARK: - Errors
public enum Error: Swift.Error{
    case paymentCannotBeProccesed,
         cardDeclined,
         networkOutOfReach
}

//MARK: - Director
struct PaymentsBackEnd {
    let strategy: PaymentStrategy
    
    func payWith(_ card: CreditCard) throws {
        print("Proccesing payment..")
        try strategy.payWith(card)
    }
}
//MARK: - Strategy Behavior
protocol PaymentStrategy {
    func payWith(_ card: CreditCard) throws
}
//MARK: - Strategy Conformers
struct VisaStrategy : PaymentStrategy {
    func payWith(_ card: CreditCard) throws {
        print("Paying with Visa..")
    }
}

struct MasterCardStrategy: PaymentStrategy  {
    func payWith(_ card: CreditCard) throws {
        print("Paying with Master Card..")
    }
}
//MARK: - Example

///Creating the Builder ///
func main(){
    let builder = CreditCardBuilder()
    ///Updating Builder properties ///
    builder.setPaymentMethod(.credit)
    builder.setCardType(.masterCard)
    builder.setCardCode(1245)
    builder.setCardNumber("5414-3414-4134-1434")
    ///Building a card
    guard let card  = try? builder.build() else {
        return
    }
    /// create and inform the Director
    let payment = PaymentsBackEnd(strategy: card.paymentStrategy)
    /// making an attempt to pay using the card
    do {
        try payment.payWith(card)
    } catch let e  {
        if let e = e as? Error{
            switch e {
            case .paymentCannotBeProccesed:
                print("Unknown Error")
            case .cardDeclined:
                print("Your card was decline , contact your card company if you think a mistake was made.")
            case .networkOutOfReach:
                print("You must be online and connected to network services to purchase.")
            }
        }
        //Handle other errors..
    }
    print(card)
}
main()
