//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Margarita Xiques on 12/08/22.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameandlastnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatpasswordTextField: UITextField!
    
    // MARK: - IBActions
    
    
    @IBAction func registerButtonAction() {
        view.endEditing(true)
        performRegister()
     
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    

    private func setupUI() {
        registerButton.clipsToBounds = true
        registerButton.layer.cornerRadius = registerButton.frame.height / 2
    }
    
    private func performRegister() {
        
        guard
            let email = emailTextField.text,
            !email.isEmpty,
            isValidEmailAddress(emailAddressString: email)
        else {
           NotificationBanner(title: "Error",
                              subtitle: "Es necesario ingresar un correo para su registro",
                              style: .warning).show()
            return
        }
        
        guard
            let nameandlastname = nameandlastnameTextField.text,
            !nameandlastname.isEmpty
        else {
            NotificationBanner(title: "Error",
                               subtitle: "Es necesario ingresar su nombre y apellido",
                               style: .warning).show()
            return
        }
        
        guard
            let password = passwordTextField.text,
            !password.isEmpty
        else {
            NotificationBanner(title: "Error",
                               subtitle: "Es necesario ingresar una contraseña",
                               style: .warning).show()
            return
        }
        
        guard
            let repeatpassword = repeatpasswordTextField.text,
            !repeatpassword.isEmpty,
            repeatpassword == password
        else {
            NotificationBanner(title: "Error",
                               subtitle: "Valida la contraseña ingresada",
                               style: .warning).show()
            return
        }
        
        //        NotificationBanner(title: "Bienvenido",
        //                           subtitle: "Registro Exitoso!!",
        //                           style: .success).show()
        //

        // Crear request
        let request = RegisterRequest(email: email, password: password, names: nameandlastname)
        
        postRegisterData(request)
        
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
    
    private func navigateToHome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.performSegue(withIdentifier: "showHome", sender: nil)
        }
        
    }
    
    private func postRegisterData(_ request: RegisterRequest) {
        // Indicar la carga del usuario
        SVProgressHUD.show()
        
        // Llamar al servicio
        SN.post(endpoint: Endpoints.register,
                model: request) { (response: SNResultWithEntity<LoginRegisterResponse, ErrorResponse>) in
            SVProgressHUD.dismiss()
            
            switch response {
            case .success(let user):
                NotificationBanner(subtitle: "Bienvenido \(user.user.names)",
                                   style: .success).show()
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                self.navigateToHome()
                
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: error.localizedDescription,
                                   style: .danger).show()
                
            case .errorResult(let entity):
                NotificationBanner(title: "Intentalo de nuevo",
                                   subtitle: entity.error,
                                   style: .warning).show()
            }
        }
    }
}
