//
//  Payment.swift
//  Courses
//
//  Created by Руслан on 02.09.2024.
//

import SwiftyJSON
import TinkoffASDKCore
import TinkoffASDKUI
import CryptoKit
import UIKit
import Alamofire


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


    // MARK: - Оплата
    func cardList(_ viewController: UIViewController, email: String) {
        self.email = email
        do {
            let sdk = try AcquiringUISDK(coreSDKConfiguration: coreSDKConfiguration, uiSDKConfiguration: uiSDKConfiguration)
            sdk.presentCardList(on: viewController, customerKey: email)

        } catch {
            assertionFailure("\(error)")
        }
    }

    func configure(_ viewController: UIViewController, email: String, price: Int, completion: @escaping (PaymentResult) -> ()) {
        self.email = email
        do {
            let sdk = try AcquiringUISDK(coreSDKConfiguration: coreSDKConfiguration, uiSDKConfiguration: uiSDKConfiguration)
            let config = MainFormUIConfiguration(orderDescription: "Оплата курса")
            sdk.presentMainForm(on: viewController, paymentFlow: paymentFlow(price: Int64(price)), configuration: config, completion: completion)
        } catch {
            assertionFailure("\(error)")
        }
    }


    private func paymentFlow(price: Int64) -> PaymentFlow {


        let orderOptions = OrderOptions(
            orderId: UUID().uuidString,
            amount: price * 100,
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

    
    // MARK: - Вывод
    
    
    func fetchFunds(payment: PaymentMethod) async throws {
        let url = Constants.url + "api/v1/payments/request-funds"
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        var parameters: Parameters
        
        
        switch payment {
        case .card:
            parameters = [
                "card_number": payment.cardNumber!,
                "amount": "\(payment.amount)",
            ]
        case .sbp:
            parameters = [
                "phone_number": payment.phoneNumber!,
                "amount": "\(payment.amount)",
                "bank_name": payment.bank!
            ]
        }
        
        let response = AF.request(url, method: .post, parameters: parameters, headers: headers).serializingData()
        let value = try await response.value
        let code = await response.response.response?.statusCode
        let json = JSON(value)
        if code != 201 {
            if let dictionary = json.dictionary {
                let error = dictionary.first!.value[0].stringValue
                throw ErrorNetwork.runtimeError(error)
            }else {
                throw ErrorNetwork.runtimeError("Неизвестная ошибка")
            }
        }
    }
    
}
