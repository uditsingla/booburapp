//
//  CheckBoxCell.swift
//  AdForest
//
//  Created by apple on 5/11/18.
//  Copyright © 2018 apple. All rights reserved.
//

import UIKit

class CheckBoxCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView!{
        didSet{
            containerView.addShadowToView()
        }
    }
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    
    //MARK:- Properties
    var dataArray = [AdPostValue]()
    var checkBoxID = ""
    var checkBoxDict = [String: String]()
    var fieldName = ""
    var fieldType = ""
    
    var selectedArray = [AdPostValue]()
    var valueArray = [String]()
    var dict = [String: String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK:- Table View Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CehckCell = tableView.dequeueReusableCell(withIdentifier: "CehckCell", for: indexPath) as! CehckCell
        
        let objData = dataArray[indexPath.row]
        
        if let title = objData.name {
            cell.lblName.text = title
        }
        
        cell.btnFull = { () in

            if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                    if self.valueArray.contains(objData.id) {
                }
                else {
                }
            }
            else {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                    if self.valueArray.contains(objData.id) {
                }
                else {
                    self.valueArray.append(objData.id)
                    self.dict[self.fieldName] = objData.id
                }
            }
        }
        return cell
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}



class CehckCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var oltFullButton: UIButton!
   
    //MARK:- Properties
    
    var btnCheck: (()->())?
    var btnFull: (()->())?
    
    //MARK:- View life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    //MARK:- IBActions
    
    @IBAction func actionFullButton(_ sender: Any) {
        self.btnFull?()
    }
}


