//
//  RazorpayView.swift
//  FashionStore
//
//  Created by MUNAVAR PM on 25/12/23.
//


import Razorpay
import UIKit
import Foundation
import SwiftUI

struct RazorPayView: UIViewControllerRepresentable {
    @ObservedObject var productManagerViewModel: ProductManagerViewModel
    let totalPrice: Int
    typealias UIViewControllerType = RazorpayViewController

    func makeUIViewController(context: Context) -> RazorpayViewController {
        let viewController = RazorpayViewController()
        viewController.totalPrice = totalPrice
        viewController.view.backgroundColor = .white
        viewController.productManagerViewModel = productManagerViewModel
        return viewController
    }

    func updateUIViewController(_ uiViewController: RazorpayViewController, context: Context) {}
}

final class RazorpayViewController: UIViewController, RazorpayPaymentCompletionProtocol {
    @AppStorage("TabSelection1") var TabSelection = -1
    private var razorpay: RazorpayCheckout?
    var totalPrice: Int = 0
    var productManagerViewModel: ProductManagerViewModel!
    private var hasPresentedCheckout = false

    override func viewDidLoad() {
        super.viewDidLoad()
        razorpay = RazorpayCheckout.initWithKey("rzp_test_as8Qsyvi6jv8By", andDelegate: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasPresentedCheckout else { return }
        hasPresentedCheckout = true
        DispatchQueue.main.async { [weak self] in
            self?.showPaymentForm()
        }
    }

    private func showPaymentForm() {
        guard totalPrice > 0 else {
            presentAlert(withTitle: "Alert", message: "Cart total should be greater than zero.")
            return
        }

        let options: [String: Any] = [
            "amount": "\(totalPrice * 100)", // value in the smallest currency unit
            "currency": "INR",
            "description": "one and only app you need",
            "name": "FashionStore Products",
            "prefill": [
                "contact": "9797979797",
                "email": "foo@bar.com"
            ],
            "theme": [
                "color": "#000000"
            ],
            "key": "rzp_test_as8Qsyvi6jv8By"
        ]
        print(options)
        razorpay?.open(options, displayController: self)
    }

    func onPaymentError(_ code: Int32, description str: String) {
        print("error:", code, str)
        presentAlert(withTitle: "Alert", message: str)
    }

    func onPaymentSuccess(_ payment_id: String) {
        print("success:", payment_id)
        presentAlert(withTitle: "Success", message: "Payment Succeeded")
        productManagerViewModel.removeAllFromCart()
    }

    private func presentAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.TabSelection = 0
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true)
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
