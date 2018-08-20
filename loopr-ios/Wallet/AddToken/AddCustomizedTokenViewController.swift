//
//  AddCustomizedTokenViewController.swift
//  loopr-ios
//
//  Created by xiaoruby on 8/17/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import UIKit
import Geth
import NotificationBannerSwift
import SVProgressHUD

class AddCustomizedTokenViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // Address
    @IBOutlet weak var addressTextField: UITextField!
    
    // Token Symbol
    @IBOutlet weak var symbolTextField: UITextField!
    
    // Token Symbol
    @IBOutlet weak var decimalTextField: UITextField!
    
    // Send button
    @IBOutlet weak var sendButton: UIButton!
    
    var address: String = ""
    var symbol: String = ""
    var decimals: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setBackButton()
        self.navigationItem.title = LocalizedString("Add Custom Token", comment: "")
        
        view.theme_backgroundColor = GlobalPicker.backgroundColor
        contentView.theme_backgroundColor = GlobalPicker.cardBackgroundColor
        contentView.cornerRadius = 6
        contentView.applyShadow()
        
        // Address
        addressTextField.delegate = self
        addressTextField.tag = 0
        addressTextField.keyboardType = .alphabet
        addressTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        addressTextField.font = FontConfigManager.shared.getDigitalFont()
        addressTextField.theme_tintColor = GlobalPicker.contrastTextColor
        addressTextField.placeholder = LocalizedString("Token Address", comment: "")
        addressTextField.text = address
        addressTextField.contentMode = UIViewContentMode.bottom
        addressTextField.setLeftPaddingPoints(13)
        addressTextField.setRightPaddingPoints(32)
        addressTextField.cornerRadius = 6
        
        symbolTextField.delegate = self
        symbolTextField.tag = 1
        symbolTextField.keyboardType = .alphabet
        symbolTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        symbolTextField.font = FontConfigManager.shared.getDigitalFont()
        symbolTextField.theme_tintColor = GlobalPicker.contrastTextColor
        symbolTextField.placeholder = LocalizedString("Token Symbol", comment: "")
        symbolTextField.text = symbol
        symbolTextField.contentMode = UIViewContentMode.bottom
        symbolTextField.setLeftPaddingPoints(9)
        symbolTextField.setRightPaddingPoints(32)
        symbolTextField.cornerRadius = 6
        
        decimalTextField.delegate = self
        decimalTextField.tag = 2
        decimalTextField.keyboardType = .alphabet
        decimalTextField.keyboardAppearance = Themes.isDark() ? .dark : .default
        decimalTextField.font = FontConfigManager.shared.getDigitalFont()
        decimalTextField.theme_tintColor = GlobalPicker.contrastTextColor
        decimalTextField.placeholder = LocalizedString("Decimals of Precision", comment: "")
        decimalTextField.text = String(decimals)
        decimalTextField.contentMode = UIViewContentMode.bottom
        decimalTextField.setLeftPaddingPoints(9)
        decimalTextField.setRightPaddingPoints(32)
        decimalTextField.cornerRadius = 6
        
        // Add button
        sendButton.title = LocalizedString("Add", comment: "")
        sendButton.setupPrimary(height: 44)
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(scrollViewTap)
        scrollView.delaysContentTouches = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        addressTextField.resignFirstResponder()
        symbolTextField.resignFirstResponder()
        decimalTextField.resignFirstResponder()
    }

    @IBAction func pressedAddButton(_ sender: Any) {
        if validateAddress() && validateSymbol() && validateDecimals() {
            SVProgressHUD.show(withStatus: "Adding...")
            LoopringAPIRequest.addCustomToken(owner: CurrentAppWalletDataManager.shared.getCurrentAppWallet()!.address, tokenContractAddress: self.address, symbol: self.symbol, decimals: self.decimals) { (result, error) in
                SVProgressHUD.dismiss()
                guard error == nil && result != nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                DispatchQueue.main.async {
                    let notificationTitle = LocalizedString("Added the custom token", comment: "")
                    let banner = NotificationBanner.generate(title: notificationTitle, style: .success)
                    banner.duration = 1.5
                    banner.show()
                }
            }
        }
    }
    
    func validateAddress() -> Bool {
        if let toAddress = addressTextField.text {
            if !toAddress.isEmpty {
                if toAddress.isHexAddress() {
                    var error: NSError?
                    if GethNewAddressFromHex(toAddress, &error) != nil {
                        self.address = toAddress
                        return true
                    }
                }
                let notificationTitle = LocalizedString("Please input a correct address", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1.5
                banner.show()
            } else {
                let notificationTitle = LocalizedString("Please enter the token address", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1.5
                banner.show()
            }
        }
        return false
    }
    
    func validateSymbol() -> Bool {
        if let symbol = symbolTextField.text {
            if !symbol.isEmpty {
                self.symbol = symbol
                return true
            } else {
                let notificationTitle = LocalizedString("Please enter the token symbol", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1.5
                banner.show()
            }
        }
        return false
    }

    func validateDecimals() -> Bool {
        if let decimals = decimalTextField.text {
            if !decimals.isEmpty {
                if let intValue = decimals.integer {
                    self.decimals = Int64(intValue)
                    return true
                }
                let notificationTitle = LocalizedString("Please input a correct value for deciaml", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1.5
                banner.show()
            } else {
                let notificationTitle = LocalizedString("Please input an deciaml", comment: "")
                let banner = NotificationBanner.generate(title: notificationTitle, style: .danger)
                banner.duration = 1.5
                banner.show()
            }
        }
        return false
    }
}
