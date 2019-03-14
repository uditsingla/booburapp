//
//  ContactUsController.swift
//  AdForest
//
//  Created by Rajeev Lochan Ranga on 06/07/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class ContactUsController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var txtfld_userName: UITextField!
    @IBOutlet weak var txtFld_email: UITextField!
    @IBOutlet weak var txtFld_subject: UITextField!
    @IBOutlet weak var txtFld_message: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnSubmit.layer.cornerRadius = self.btnSubmit.frame.size.height/2
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addLeftBarButtonWithImage(#imageLiteral(resourceName: "menu"))

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func buttonSubmit_action(_ sender: UIButton) {
        guard let username = self.txtfld_userName.text else {
            return
        }
        guard let email = self.txtFld_email.text else {
            return
        }
        guard let subject = self.txtFld_subject.text else {
            return
        }
        guard let message = self.txtFld_message.text else {
            return
        }
        if username == "" {
            let alert = Constants.showBasicAlert(message: "Enter Valid Username")
            self.presentVC(alert)
        }
        else if email == "" {
            let alert = Constants.showBasicAlert(message: "Enter Valid Email Id")
            self.presentVC(alert)
        }
        else if !email.isValidEmail {
            let alert = Constants.showBasicAlert(message: "Enter Valid Email")
            self.presentVC(alert)
        }
        else if subject == "" {
            let alert = Constants.showBasicAlert(message: "Enter Valid Subject")
            self.presentVC(alert)
        }
        else if message == "" {
            let alert = Constants.showBasicAlert(message: "Enter Valid Message")
            self.presentVC(alert)
        }
        else
        {
            self.submitDetails()
        }
    }
    //MARK:- TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func submitDetails() {
        let params = ["name":self.txtfld_userName.text,"email":self.txtFld_email.text,"subject":self.txtFld_subject.text,"message":self.txtFld_message.text]
        let URL = "https://www.boobur.com/wp-json/adforest/v1/profile/contact"
        NetworkHandler.postRequest(url: URL, parameters: params, success: { (successResponse) in
            let dictionary = successResponse as! [String: Any]
            self.txtFld_email.text = ""
            self.txtFld_message.text = ""
            self.txtFld_subject.text = ""
            self.txtfld_userName.text = ""
            let alert = AlertView.prepare(title: "", message: "Submitted succesfully", okAction: {
            })
            self.presentVC(alert)
            print(dictionary)
        }) {  (error) in
            let alert = AlertView.prepare(title: "", message: error.message, okAction: {
            })
            self.presentVC(alert)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
