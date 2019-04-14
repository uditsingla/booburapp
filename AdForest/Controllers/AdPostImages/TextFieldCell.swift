//
//  TextFieldCell.swift
//  AdForest
//
//  Created by apple on 5/9/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

protocol AddDataDelegate {
    func addToFieldsArray(obj: AdPostField, index: Int, isFrom: String, title: String)
}

protocol textValDelegate {
    func textVal(value: String,indexPath: Int, fieldType:String, section: Int,fieldNam:String)
}

class TextFieldCell: UITableViewCell, UITextFieldDelegate {

    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var txtType: UITextField!{
        didSet{
            txtType.delegate = self
        }
    }
    
    //MARK:- Properties
    //var delegate: AddDataDelegate?
    var fieldName = ""
    var objSaved = AdPostField()
    var selectedIndex = 0
    //var delegate : textFieldValueDelegate?
    var inde = 0
    var section = 0
    var delegate : textValDelegate?
    var fieldType = "textfield"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        objSaved.fieldVal = txtType.text
       // self.delegate?.addToFieldsArray(obj: objSaved, index: selectedIndex, isFrom: "textfield", title: "")
    }
    
    @IBAction func txtEditingStart(_ sender: UITextField) {
        if fieldName == "ad_bidding_time" && fieldType == "textfield"{
            let datePicker = ActionSheetDatePicker(title: "", datePickerMode: UIDatePickerMode.date, selectedDate: Date(), doneBlock: {
                picker, value, index in
                print("value = \(value!)")
                print("index = \(index!)")
                print("picker = \(picker!)")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let selectedDate = dateFormatter.string(from: value as! Date)
                self.txtType.text = selectedDate
                
                self.delegate?.textVal(value:selectedDate , indexPath: self.inde ,fieldType: "textfield",section:self.section,fieldNam: self.fieldName)
                return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender as! UIView)
            datePicker?.show()
        }
    }
    
    @IBAction func txtEditingChanged(_ sender: UITextField) {

        if let text = sender.text {
            //delegate?.changeText(value: text, fieldTitle: fieldName)

                delegate?.textVal(value: text, indexPath: inde,fieldType: "textfield",section:section,fieldNam: fieldName)
     
        }
    }
}
