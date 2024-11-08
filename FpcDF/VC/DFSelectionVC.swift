//
//  SelectionVC.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/12/13.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit

private let bundle = Bundle(for: DynamicForm.self)

class DFSelectionVC: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var total: PaddingLabel!
    @IBOutlet weak var bottomView: UIView!
    
    var confirm: UIBarButtonItem?
    
    var oriFormData: FormListData?
    
    var urlString: String?
    var tokenKey: String?
    var accessToken: String?
    var tokenURL: String?
    
    var formNumber = 0
    var cellNumber = 0
    var subCellNumber = 0
    var id: String?
    var oriOptionList = [DynamicInput]()
    var optionList = [DynamicInput]()
    var chosenItemList = [DynamicInput]()
    
    var defaultList:[String] = []
    
    var type: String?
    var timer: Timer?
    var searchBarTextString = ""
    var constraint: NSLayoutConstraint?
    
    var isFilter = false
    var isFirstCheck = true
    
    var isOffline = false
    
    var alertBkgView: UIView?
    var selfInputView: DFInputView!
    var selfInputText = ""
    var fontLimit = 0
    var isMultiple = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertBkgView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        selfInputView = DFInputView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 1.5, height: 300))
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "KeyValueCell", bundle: bundle), forCellReuseIdentifier: "KeyValueCell")
        
        //        confirm = UIBarButtonItem(title: "選擇項目", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toFormVC))
        
        total.layer.cornerRadius = 5
        
        constraint = NSLayoutConstraint(item: bottomView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0)
        bottomView.addConstraint(constraint!)
        
        let bottomViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(bottomViewTap))
        
        bottomView.addGestureRecognizer(bottomViewTapRecognizer)
        
        let inputButton = UIBarButtonItem(title: "自行輸入" , style: UIBarButtonItem.Style.plain, target: self, action: #selector(inputByself))
        
        let clearButton = UIBarButtonItem(title: "清除", style: UIBarButtonItem.Style.plain, target: self, action: #selector(clear))
        
        self.navigationItem.rightBarButtonItems = [inputButton, clearButton]
        //        self.navigationItem.rightBarButtonItems = [self.confirm!]
        
        if type == "singleSelection" || type == "textChoice" || type == "combineOption" {
            constraint?.constant = 0
            bottomLabel.isHidden = true
            total.isHidden = true
            
            isMultiple = false
        }else if type == "multipleSelection" || type == "textMultiChoice" || type == "checkBox" {
            constraint?.constant = 40
            bottomLabel.isHidden = false
            total.isHidden = false
            
            isMultiple = true
            
            if !chosenItemList.isEmpty {
                total.text = "\(chosenItemList.count)"
            }
        }
        
        for option in oriOptionList {
            if defaultList.contains(option.id!) {
                option.isSelected = true
                chosenItemList.append(option)
            }
        }
        
        
        if optionList.count == 0 {
            if let tokenURL = tokenURL, tokenURL != "", let accessToken = accessToken, accessToken != "" {
                DFAPI.customPost(address: tokenURL, parameters: [
                    "accessToken": accessToken,
                    "comment" : "DynamicForm"
                ]) { json in
                    //            print(json)
                    
                    if let data = json[DFJSONKey.data] {
                        
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .millisecondsSince1970
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                            
                            let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: DFDisposableToken.self)
                            print(obj)
                            let parameters = [
                                self.tokenKey!: obj.accessTokenSHA256
                            ]
                            DFAPI.customGet(address: self.urlString!, parameters: parameters) {
                                json in
                                
                                if let data = json[DFJSONKey.data] {
                                    do {
                                        
                                        let decoder = JSONDecoder()
                                        decoder.dateDecodingStrategy = .millisecondsSince1970
                                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                                        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                                        
                                        let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: FormListData.self)
                                        
                                        self.oriFormData = obj
                                        DispatchQueue.main.async {
                                            self.title = obj.formTitle
                                            self.setButtons()
                                            for cell in obj.cells {
                                                let item = DynamicInput()
                                                item.isSelected = false
                                                item.id = cell.id
                                                item.keyValueArray = cell.keyValueArray!
                                                
                                                self.optionList.append(item)
                                                self.oriOptionList.append(item)
                                            }
                                            
                                            if !self.chosenItemList.isEmpty {
                                                self.isFirstCheck = false
                                                self.optionList = self.chosenItemList
                                                self.confirm = UIBarButtonItem(title: "確認(\(self.chosenItemList.count))" , style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.toFormVC))
                                                if let tokenKey = self.tokenKey, tokenKey == "mobilefpcToken" {
                                                    self.confirm!.tintColor = .white
                                                }
                                                self.navigationItem.rightBarButtonItems?.append(self.confirm!)
                                            }
                                        
                                            self.tableView.reloadData()
                                        }
                                    } catch {
                                    }
                                }
                            }
                            
                        } catch {
                            
                        }
                    }
                }
            }
            
        }
    }
    
    @objc func clear() {
        
        self.selfInputText = " "
        
//        for option in oriOptionList {
//            if defaultList.contains(option.id!) {
//                self.selfInputText = option.name ?? " "
//            }
//        }
        
        
        self.performSegue(withIdentifier: "toFormVC", sender: nil)
    }
    
    @objc func inputByself() {
        self.selfInputView!.center = CGPoint(x: alertBkgView!.frame.size.width / 2, y: alertBkgView!.frame.size.height / 2 )
        self.alertBkgView!.addSubview(self.selfInputView!)
        
        self.view.addSubview(self.alertBkgView!)
        
        self.alertBkgView!.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        self.alertBkgView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEdit)))
        
        self.selfInputText = ""
        
        self.selfInputView.option.text = ""
        self.selfInputView.option.delegate = self
        self.selfInputView.cancelButton.addTarget(self, action: #selector(closeInputView), for: .touchUpInside)
        self.selfInputView.confirmButton.addTarget(self, action: #selector(confirmInput), for: .touchUpInside)
    }
    
    @objc func closeInputView() {
        self.selfInputText = ""
        self.selfInputView.removeFromSuperview()
        self.alertBkgView?.removeFromSuperview()
    }
    
    @objc func endEdit() {
        self.view.endEditing(true)
    }
    
    @objc func confirmInput() {
        self.selfInputText = self.selfInputView.option.text
        
        self.performSegue(withIdentifier: "toFormVC", sender: nil)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        
        if self.fontLimit != 0, textView.text!.count >= fontLimit {
            DFUtil.DFTipMessageAndConfirm(self, msg: "超過\(self.fontLimit)字數限制，請修正", callback: {
                _ in
               
            })
        }
    }
    
    func setButtons() {
        for (index, button) in oriFormData!.buttons.enumerated() {
            let buttonItem = UIBarButtonItem(title: button.name, style: UIBarButtonItem.Style.plain, target: self, action: #selector(buttonClick))
            
            buttonItem.tag = index
            if let tokenKey = self.tokenKey, tokenKey == "mobilefpcToken" {
                buttonItem.tintColor = .white
            }
            self.navigationItem.rightBarButtonItems?.append(buttonItem)
        }
    }
    
    @objc func buttonClick(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        optionList = []
        oriOptionList = []
        let button = oriFormData?.buttons[sender.tag]
        
        if button?.type == "searchPost" {
            DFAPI.customPost(address: tokenURL!, parameters: [
                "accessToken": accessToken!,
                "comment" : "DynamicForm"
            ]) { json in
                //            print(json)
                
                if let data = json[DFJSONKey.data] {
                    
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .millisecondsSince1970
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                        
                        let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: DFDisposableToken.self)
                        print(obj)
                        DispatchQueue.main.async {
                            let parameters = [
                                "pattern": self.searchBar.text!,
                                "accessTokenSHA256": obj.accessTokenSHA256
                            ]
                            
                            DFAPI.customPost(address: (button?.url!)!, parameters: parameters) {
                                json in
                                
                                if let data = json[DFJSONKey.data] {
                                    do {
                                        
                                        let decoder = JSONDecoder()
                                        decoder.dateDecodingStrategy = .millisecondsSince1970
                                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                                        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                                        
                                        let obj = try DFUtil.decodeJsonStringAndReturnArrayObject(string: jsonString, type: DynamicInput.self)
                                        
                                        self.setData(data: obj)
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    } catch {
                                    }
                                }
                            }
                        }
                        
                    } catch {
                        
                    }
                }
            }
            
        }else if button?.type == "searchGet" {
            let urlString = (button?.url!)! + searchBar.text!
            let urlArray = urlString.split(separator: "?")
            
            if urlArray.count > 1 {
                let url = urlArray[0]
                let param = urlArray[1]
                let mainParam = param.split(separator: "=")
                let parameters = [
                    String(mainParam[0]) : String(mainParam[1])
                ]
                
                print(parameters)
                DFAPI.customPost(address: tokenURL!, parameters: [
                    "accessToken": accessToken!,
                    "comment" : "DynamicForm"
                ]) { json in
                    //            print(json)
                    
                    if let data = json[DFJSONKey.data] {
                        
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .millisecondsSince1970
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                            
                            let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: DFDisposableToken.self)
                            print(obj)
                            
                            DispatchQueue.main.async {
                                let parameters = [
                                    "pattern": self.searchBar.text!,
                                    "accessTokenSHA256": obj.accessTokenSHA256
                                ]
                                
                                DFAPI.customGet(address: String(url), parameters: parameters) {
                                    json in
                                    
                                    if let data = json[DFJSONKey.data] {
                                        do {
                                            
                                            let decoder = JSONDecoder()
                                            decoder.dateDecodingStrategy = .millisecondsSince1970
                                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                                            
                                            let obj = try DFUtil.decodeJsonStringAndReturnArrayObject(string: jsonString, type: DynamicInput.self)
                                            
                                            self.setData(data: obj)
                                            
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                        } catch {
                                        }
                                    }
                                }
                            }
                            
                        } catch {
                            
                        }
                    }
                }
                
            }
            
        }
    }
    
    func setData(data: [DynamicInput]) {
        for cell in data {
            let item = DynamicInput()
            item.isSelected = false
            item.id = cell.id
            item.name = cell.name
            item.jsonString = cell.jsonString
            item.keyValueArray = cell.keyValueArray!
            
            self.optionList.append(item)
            self.oriOptionList.append(item)
        }
        
        for chosenItem in self.chosenItemList {
            for (index, item) in self.optionList.enumerated() {
                if chosenItem.id == item.id {
                    self.optionList[index].isSelected = true
                    continue
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for chosenItem in chosenItemList {
            for (index, item) in optionList.enumerated() {
                if chosenItem.id == item.id {
                    optionList[index].isSelected = true
                    continue
                }
            }
        }
        
        tableView.reloadData()
    }
    
    @objc func bottomViewTap(sender:UITapGestureRecognizer) {
        let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "DFChosenModifyVC") as? DFChosenModifyVC
        
        //        let vc = UIStoryboard(name: "Main", bundle: bundle).instantiateViewController(withIdentifier : "ChosenModifyVC") as? DFChosenModifyVC
        
        vc?.oriChosenItemList = chosenItemList
        vc?.chosenItemList = chosenItemList
        vc?.tokenKey = self.tokenKey
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        if let tokenKey = self.tokenKey, tokenKey == "mobilefpcToken" {
            backItem.tintColor = .white
        }
        self.navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func toFormVC(sender: AnyObject) {
        
        self.performSegue(withIdentifier: "toFormVC", sender: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let t = timer {
            t.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(doSearch), userInfo: nil, repeats: false)
        
        searchBarTextString = searchText
        
    }
    
    @objc func doSearch() {
        if isFilter {
            optionList = []
            if searchBarTextString != "" {
                for option in oriOptionList {
                    if (option.name?.uppercased().contains(searchBarTextString.uppercased()))! {
                        optionList.append(option)
                    }
                }
                
            }else {
                optionList = oriOptionList
            }
            
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: KeyValueCell = tableView.dequeueReusableCell(withIdentifier: "KeyValueCell", for: indexPath) as! KeyValueCell
        
        let option = optionList[indexPath.row]
        
        let checkTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(checkTap))
        
        if type == "singleSelection" || type == "textChoice" || type == "combineOption" {
            cell.imageConstraint?.constant = 0
        }else if type == "multipleSelection" || type == "textMultiChoice" || type == "checkBox" {
            cell.imageConstraint?.constant = 25
        }
        
        
        if option.isSelected! {
            cell.checkIcon.image = UIImage(named: "df_icon_checksign_checked", in: bundle, compatibleWith: nil)
        }else {
            cell.checkIcon.image = UIImage(named: "df_icon_checksign_unchecked", in: bundle, compatibleWith: nil)
        }
        
        cell.checkIcon.addGestureRecognizer(checkTapRecognizer)
        
        cell.checkIcon.tag = indexPath.row
        
        DFUtil.setKeyValueData(cell: cell, keyValueArray: option.keyValueArray!)
        
        return cell
    }
    
    
    @objc func checkTap(sender:UITapGestureRecognizer) {
        let indexPath = IndexPath(row: (sender.view?.tag)!, section: 0)
        let choseOption = optionList[(sender.view?.tag)!]
        
        self.setChosenCell(indexPath: indexPath, choseOption: choseOption)
        
       
        
    }
    
    func setChosenCell(indexPath: IndexPath, choseOption: DynamicInput) {
        let cell: KeyValueCell = tableView.cellForRow(at: indexPath) as! KeyValueCell
        

        choseOption.isSelected = !choseOption.isSelected!
        
        if choseOption.isSelected! {
            cell.checkIcon.image = UIImage(named: "df_icon_checksign_checked", in: bundle, compatibleWith: nil)
            chosenItemList.append(choseOption)
        }else {
            cell.checkIcon.image = UIImage(named: "df_icon_checksign_unchecked", in: bundle, compatibleWith: nil)
            
            for (index, option) in chosenItemList.enumerated() {
                if option.id == choseOption.id {
                    chosenItemList.remove(at: index)
                    break
                }
            }
        }
        
        total.text = "\(chosenItemList.count)"
        confirm = UIBarButtonItem(title: "確認(\(chosenItemList.count))" , style: UIBarButtonItem.Style.plain, target: self, action: #selector(toFormVC))
        //        saveFile!.image = UIImage(named: "top_save_button")
        if let tokenKey = self.tokenKey, tokenKey == "mobilefpcToken" {
            confirm!.tintColor = .white
        }
//        if self.navigationItem.rightBarButtonItems?.count == 1 {
//            self.navigationItem.rightBarButtonItems?.append(confirm!)
//        }else {
            confirm?.title = "確認(\(chosenItemList.count))"
            if !isFirstCheck {
                self.navigationItem.rightBarButtonItems?.popLast()
            }else {
                isFirstCheck = false
            }
            self.navigationItem.rightBarButtonItems?.append(confirm!)
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
//        if type == "singleSelection" || type == "textChoice" {
        
        if isMultiple {
            let choseOption = optionList[indexPath.row]
            
            self.setChosenCell(indexPath: indexPath, choseOption: choseOption)
        }else {
            let choseOption = optionList[indexPath.row]
            chosenItemList = []
            chosenItemList.append(choseOption)
            self.performSegue(withIdentifier: "toFormVC", sender: nil)
        }
            
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func unwindToSelectionVC(segue: UIStoryboardSegue) {
        if segue.source is DFChosenModifyVC {
            if let selectionVC = segue.source as? DFChosenModifyVC {
                self.chosenItemList = selectionVC.chosenItemList
                total.text = "\(chosenItemList.count)"
                
                confirm?.title = "確認(\(chosenItemList.count))"
                self.navigationItem.rightBarButtonItems?.popLast()
                self.navigationItem.rightBarButtonItems?.append(confirm!)
            }
        }
    }
}
