//
//  ViewController.swift
//  FCA
//
//  Created by Lakshmi Narayanan N on 13/08/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit
import FirebaseAuth

enum FBAuthError: Error {
    case invalidPhoneNumber
}

class ViewController: UIViewController {
    
    @IBOutlet weak var phoneNumberLoginButton: UIButton!
    @IBOutlet weak var validationCodeView: UIView!
    @IBOutlet weak var validationCodeTextField: UITextField!
    
    var validationCode = ""
    var verificationId: String {
        get {
            return UserDefaults.standard.object(forKey: "authVerificationID") as! String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "authVerificationID")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        validationCodeView.isHidden = true
        validationCodeView.alpha = 0.0
    }
    
    // MARK:- IB Actions
    @IBAction func phoneNumberLoginButtonAction(_ sender: Any) {
        let phoneNumber = "+919791212138"
        validate(phoneNumber: phoneNumber) { (status, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(error: error)
                    return
                }
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.validationCodeView.isHidden = false
                    self.validationCodeView.alpha = 1.0
                });
            }
        }
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        validationCodeTextField.resignFirstResponder()
        if validationCode.count > 0 {
            validate(verificationCode: validationCode) { (error) in
                if let error = error {
                    self.showAlert(error: error)
                    return
                }
            }
            
            print("**** Phone number verified ****")
        }
    }
    
    // MARK:-
    func showAlert(error: Error) {
        print(error.localizedDescription)
    }
}

// MARK:- Textfield delegates
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validationCode = textField.text ?? ""
    }
}

// MARK:- Phone number Login
extension ViewController {
    func validate(phoneNumber: String, callBack: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [unowned self] (verificationID, error) in
            if let verificationID = verificationID {
                self.verificationId = verificationID
                callBack(true, error)
                return
            }
            callBack(false, nil)
        }
    }
    
    func validate(verificationCode: String, callBack: @escaping (_ error: Error?) -> ()) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCode)
        Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
            callBack(error)
        }
    }
}

