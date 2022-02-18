//
//  Utilities.swift
//  NajlaAbothnainBeltExam
//
//  Created by Najla on 15/01/2022.
//

import Foundation
import UIKit

class Utilities {
   
    static func isPasswordValid(_ password : String) -> Bool {
        //regular Exprssion to make the password secure:
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
}
