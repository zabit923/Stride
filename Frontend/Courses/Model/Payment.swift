//
//  Payment.swift
//  Courses
//
//  Created by Руслан on 02.09.2024.
//

import Foundation
import TinkoffASDKCore
import TinkoffASDKUI
import CryptoKit
import UIKit


class Payment {

    var email = ""
    let credential = AcquiringSdkCredential(
        terminalKey: "1725028795107",
        publicKey: "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv5yse9ka3ZQE0feuGtemYv3IqOlLck8zHUM7lTr0za6lXTszRSXfUO7jMb+L5C7e2QNFs+7sIX2OQJ6a+HG8kr+jwJ4tS3cVsWtd9NXpsU40PE4MeNr5RqiNXjcDxA+L4OsEm/BlyFOEOh2epGyYUd5/iO3OiQFRNicomT2saQYAeqIwuELPs1XpLk9HLx5qPbm8fRrQhjeUD5TLO8b+4yCnObe8vy/BMUwBfq+ieWADIjwWCMp2KTpMGLz48qnaD9kdrYJ0iyHqzb2mkDhdIzkim24A3lWoYitJCBrrB2xM05sm9+OdCI1f7nPNJbl5URHobSwR94IRGT7CJcUjvwIDAQAB"
    )

    var coreSDKConfiguration : AcquiringSdkConfiguration {
        return AcquiringSdkConfiguration(credential: credential, server: .prod)
    }

    let uiSDKConfiguration = UISDKConfiguration()
    

    
    func configure(_ viewController: UIViewController, email: String) {
        self.email = email
        do {
            let sdk = try AcquiringUISDK(coreSDKConfiguration: coreSDKConfiguration, uiSDKConfiguration: uiSDKConfiguration)
            let config = MainFormUIConfiguration(orderDescription: "Оплата курса")
            sdk.presentMainForm(on: viewController, paymentFlow: paymentFlow(), configuration: config) { result in
                switch result {
                case .succeeded(let succ):
                    print(succ)
                case .failed(let error):
                    print(error)
                case .cancelled(_):
                    break
                }
            }
        } catch {
            assertionFailure("\(error)")
        }
    }

    
    private func paymentFlow() -> PaymentFlow {
        
        
        let orderOptions = OrderOptions(
            orderId: UUID().uuidString,
            amount: 100,
            description: "Покупка курса",
            savingAsParentPayment: false
        )
        let customerOptions = CustomerOptions(
            customerKey: email,
            email: email
        )
        let paymentCallbackURL = PaymentCallbackURL(
            successURL: "SUCCESS_URL",
            failureURL: "FAIL_URL"
        )
        
        let options = PaymentOptions(orderOptions: orderOptions, customerOptions: customerOptions, paymentCallbackURL: paymentCallbackURL)
        let paymentFlow: PaymentFlow = .full(paymentOptions: options)
        return paymentFlow
    }
    
}
