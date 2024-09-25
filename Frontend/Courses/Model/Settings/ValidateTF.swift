//
//  ValidateTF.swift
//  Courses
//
//  Created by Руслан on 14.09.2024.
//

import UIKit

class ValidateTF {
    
    func nameAndSurname(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        let trimmedText = updatedText.trimmingCharacters(in: .whitespacesAndNewlines)

        let allowedCharacterSet = CharacterSet.letters
        let characterSet = CharacterSet(charactersIn: string)

        let isAllowedCharacter = allowedCharacterSet.isSuperset(of: characterSet)

        return isAllowedCharacter && trimmedText.count <= 15
    }


    
    func phone(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        if newString.format(with: "+X (XXX) XXX-XXXX").count >= 2 {
            textField.text = newString.format(with: "+X (XXX) XXX-XXXX")
            return false
        } else {
            return false
        }
    }
    
}
