//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 12/08/22.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD
import Alamofire

extension UIColor {
    static var customGreen: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor {(trait: UITraitCollection) -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    // aqui estamos en dark mode
                    return .white
                } else {
                    // aquí estamos en light mode
                    return .systemGreen
                }
            }
        } else {
            // aquí es menor de iOS 13
            return .systemGreen
        }
    }
    
    static var customTitleButtom: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (trait: UITraitCollection) -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    return .black
                } else {
                    return .white
                }
            }
        } else {
            return .white
        }
    }
}


class LoginViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var sesionswitch: UISwitch!
    
    // MARK: - IBActions
    
    
    @IBAction func loginButtonAction() {
        view.endEditing(true)
        performLogin()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkStoragePassword()
        setupUI()
        checkStorageEmail()
    }
    
    // MARK: - Private Methods
    
    private func setupUI () {
        loginButton.clipsToBounds = true
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        
        loginButton.backgroundColor =  UIColor.customGreen
        loginButton.titleLabel?.textColor = UIColor.customTitleButtom
        
        
        // Forzar a que la app no tenga Dark Mode
        if #available(iOS 13.0, *) {
           // overrideUserInterfaceStyle = .light
        }
    }
    
    private func performLogin() {
        
        guard
            let email = emailTextField.text,
            !email.isEmpty,
            isValidEmailAddress(emailAddressString: email)
        else {
            NotificationBanner(title: "Error",
                               subtitle: "Debes ingresar un correo correcto",
                               style: .warning).show()
            return
        }
        
        guard
            let password = passwordTextField.text,
            !password.isEmpty
        else{
            NotificationBanner(title: "Error",
                               subtitle: "Debes escribir una contraseña",
                               style: .warning).show()
            return
            
        }
        
        //        NotificationBanner(title: "Inicio Exitoso",
        //                           subtitle: "Has iniciado con el correo \(email)",
        //                           style: .success).show()
        
        if sesionswitch.isOn {
            storageEmail.set(email, forKey: emailKey)
            storagePassword.set(password, forKey: passwordKey)
        } else {
            storagePassword.removeObject(forKey: passwordKey)
            storageEmail.removeObject(forKey: emailKey)
        }
        
        // Crear request
        let request = LoginRequest(email: email , password: password)
        
        postLoginData(request)
    }
    
    private func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    private func postLoginData(_ request: LoginRequest) {
        // Iniciamos la carga
        SVProgressHUD.show()
        
        // Llamar a libreria de red
        SN.post(endpoint: Endpoints.login,
                model: request) { (response: SNResultWithEntity<LoginRegisterResponse, ErrorResponse>) in
            
            SVProgressHUD.dismiss()
            
            switch response {
            case .success(let user):
                NotificationBanner(subtitle: "Bienvenido \(user.user.names)",
                                   style: .success).show()
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token )
                self.navigateToHome()
                
            case .error(let error):
                NotificationBanner(title:"Error",
                                   subtitle: error.localizedDescription,
                                   style: .danger).show()
                
            case .errorResult(let entity):
                NotificationBanner(subtitle: "Inténtalo de nuevo: \(entity.error)",
                                   style: .warning).show()
            }
        }
    }
    
    private func navigateToHome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.performSegue(withIdentifier: "showHome", sender: nil)
        }
        DispatchQueue.main.async {
            <#code#>
        }
    }
    
    private func checkStorageEmail() {
        if let storedEmail = storageEmail.string(forKey: emailKey){
            emailTextField.text = storedEmail
            sesionswitch.isOn = true
        } else {
            sesionswitch.isOn = false
        }
    }
    
    private func checkStoragePassword() {
        if let storedPassword = storagePassword.string(forKey: passwordKey) {
            passwordTextField.text = storedPassword
            sesionswitch.isOn = true
            
        }
    }
    
    
    private let emailKey = UserDefaults.Keys.email.rawValue
    private let storageEmail = UserDefaults.standard
    private let storagePassword = UserDefaults.standard
    private let passwordKey = UserDefaults.Keys.password.rawValue
    
}


