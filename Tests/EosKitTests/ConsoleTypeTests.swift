import XCTest
@testable import EosKit

final class ConsoleTypeTests: XCTestCase {
    
/*
case ETCNomad = "ETCNomad"
case ETCNomad_Puck = "ETCNomad Puck"
case Element = "Element"
case Element2 = "Element 2"
case Ion = "Ion"
case IonXE = "IonXE"
case IonXE20 = "IonXE 20"
case Eos = "Eos"
case Eos_RVI = "Eos RVI"
case Eos_RPU = "Eos RPU"
case Ti = "Eos Ti"
case Gio = "Gio"
case Gio_5 = "Gio@5"
case unknown
 */
    
    func testInits() {

        let ETCNomad = EosConsole.ConsoleType(rawValue: "ETCnomad")
        XCTAssertEqual(ETCNomad, EosConsole.ConsoleType.nomad)
        
        let ETCNomad_Puck = EosConsole.ConsoleType(rawValue: "ETCnomad Puck")
        XCTAssertEqual(ETCNomad_Puck, EosConsole.ConsoleType.nomadPuck)
        
        let unknown = EosConsole.ConsoleType(rawValue: "unknown")
        XCTAssertEqual(unknown, EosConsole.ConsoleType.unknown)
        
    }

    static var allTests = [
        ("testInits", testInits),
    ]
}
