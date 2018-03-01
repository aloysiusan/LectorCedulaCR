//
//  Person.swift
//  Scanner
//
//  Created by Luis Alvarado on 3/1/18.
//  Copyright © 2018 Aloysiusan. All rights reserved.
//

import Foundation
class Person : NSObject{
    let identification : String
    let name : String
    let lastName : String
    
    override var description: String {
        return "{ identification = \(identification), name = \(name), lastName = \(lastName) }"
    }
    
    init(rawString : String){
        
        let identificationEndIndex = rawString.index(rawString.startIndex, offsetBy: 9)
        let firstLastNameEndIndex = rawString.index(rawString.startIndex, offsetBy: 35)
        let secondLastNameEndIndex = rawString.index(rawString.startIndex, offsetBy: 61)
        let nameEndIndex = rawString.index(rawString.startIndex, offsetBy: 91)
        
        self.identification = String(rawString[..<identificationEndIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.name = String(rawString[secondLastNameEndIndex..<nameEndIndex]).capitalized.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lastName = "\(String(rawString[identificationEndIndex..<firstLastNameEndIndex]).trimmingCharacters(in: .whitespacesAndNewlines)) \(String(rawString[firstLastNameEndIndex..<secondLastNameEndIndex]).trimmingCharacters(in: .whitespacesAndNewlines))".capitalized
    }
}
