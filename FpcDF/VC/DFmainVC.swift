//
//  ViewController.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/11/21.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit
import SafariServices
import MobileCoreServices

private let bundle = Bundle(for: DynamicForm.self)

public class DFmainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //存放原始表單資料
    var oriFormData: FormListData?
    var keyboardPresented = false
    var screenHeight:CGFloat = 0.0
    
    var formDataList = [FormData]()
    
    //存放各個dataFormatter
    var dateFormatterList = [dateFormatterObj]()
    
    var urlString: String?
    var tokenKey: String?
    var accessToken: String?
    var tokenURL: String?
    
    var activityIndicator: UIActivityIndicatorView!
    var isFirstLayer = true
    
    fileprivate var heightDictionary: [Int : CGFloat] = [:]
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        screenHeight = self.view.bounds.height
        
        //        let FormTitleCellNib = UINib.init(nibName: "FormTitleCell", bundle: Bundle(for: DynamicForm.self ))
        
        tableView.register(UINib(nibName: "FormTitleCell", bundle: bundle), forCellReuseIdentifier: "FormTitleCell")
        tableView.register(UINib(nibName: "FormTextFieldCell", bundle: bundle), forCellReuseIdentifier: "FormTextFieldCell")
        tableView.register(UINib(nibName: "FormChoiceCell", bundle: bundle), forCellReuseIdentifier: "FormChoiceCell")
        tableView.register(UINib(nibName: "FormTextAreaCell", bundle: bundle), forCellReuseIdentifier: "FormTextAreaCell")
        tableView.register(UINib(nibName: "KeyValueCell", bundle: bundle), forCellReuseIdentifier: "KeyValueCell")
        tableView.register(UINib(nibName: "fileCell", bundle: bundle), forCellReuseIdentifier: "fileCell")
        tableView.register(UINib(nibName: "DynamicFieldCell", bundle: bundle), forCellReuseIdentifier: "DynamicFieldCell")
        tableView.register(UINib(nibName: "SingleSelectionCell", bundle: bundle), forCellReuseIdentifier: "SingleSelectionCell")
        tableView.register(UINib(nibName: "UploadCell", bundle: bundle), forCellReuseIdentifier: "UploadCell")
        tableView.register(UINib(nibName: "DFSignCell", bundle: bundle), forCellReuseIdentifier: "DFSignCell")
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        self.navigationItem.rightBarButtonItems = []
        
        if isFirstLayer {
            let backItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
            if let tokenKey = tokenKey, tokenKey == "mobilefpcToken" {
                backItem.tintColor = .white
            }
            navigationItem.leftBarButtonItem = backItem
        }
        
        //先使用拋棄式token取得個人身份
        dfShowActivityIndicator()
        if let tokenURL = tokenURL, tokenURL != "", let accessToken = accessToken, accessToken != "" {
            DFAPI.customPost(address: tokenURL, parameters: [
                "accessToken": accessToken,
                "comment" : "DynamicForm"
            ]) {
                json in
                print(json)
                if let data = json[DFJSONKey.data] {
                    
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .millisecondsSince1970
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                        
                        let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: DFDisposableToken.self)
                        
                        if let urlString = self.urlString {
                            self.load(urlString: urlString, accessToken: obj.accessTokenSHA256)
                        }
                        
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        dfStopActivityIndicator()
    }
    
    //依照是否有導覽列決定返回的動作
    @objc func back() {
        if isModal() {
            self.dismiss(animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    //檢查APP是否有使用導覽列
    func isModal() -> Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
    
    //getForm 取得表單
    func load(urlString: String, accessToken: String) {
        
        let parameters = [
            tokenKey!: accessToken
            ] as [String : Any]
        
        //後端API會先檢查版本是否更新，通過後，框架仍須檢查是版本是否符合form的版本
        DFAPI.customGet(address: urlString, parameters: parameters) {
            json in
            
            if let result = json["result"] as? String {
                if result == DFResult.APP_FORCE_UPDATE {
                    self.showUpdate(json: json)
                }else {
                    if let data = json[DFJSONKey.data] as? [String: Any] {
                        DispatchQueue.main.async {
                            do {
                                print(data)
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategy = .millisecondsSince1970
                                let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                                
                                let versionCode = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: DFVersionCode.self)
                                
                                //檢查form與框架的版本是否符合
                                if DFUtil.versionCode < versionCode.versionCode! {
                                    DFAPI.customPost(address: self.tokenURL!, parameters: [
                                        "accessToken": self.accessToken!,
                                        "comment" : "DynamicForm"
                                    ]) {
                                        json in
                                        
                                        if let data = json[DFJSONKey.data] {
                                            
                                            do {
                                                let decoder = JSONDecoder()
                                                decoder.dateDecodingStrategy = .millisecondsSince1970
                                                let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                                                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                                                
                                                let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: DFDisposableToken.self)
                                                
                                                let parameters = [
                                                    self.tokenKey!: obj.accessTokenSHA256
                                                ]
                                                
                                                DFAPI.customPost(address: DFAPI.versionCodeCheckUrl, parameters: parameters) { json in
                                                    print(json)
                                                    self.dfStopActivityIndicator()
                                                    self.showUpdate(json: json)
                                                }
                                                
                                            } catch {
                                                
                                            }
                                        }
                                        
                                    }
                                    
                                }else {
                                    let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: FormListData.self)
                                    self.oriFormData = obj
                                    self.clear()
                                    
                                    self.title = obj.formTitle
                                    self.setButtons()
                                    self.setFormData()
                                    self.dfStopActivityIndicator()
                                    self.tableView.reloadData()
                                }
                            } catch {
                            }
                        }
                    }
                }
            }
        }
    }
    
    //顯示更新畫面
    func showUpdate(json: [String: Any]){
        
        if let storeAppURL = json[DFJSONKey.storeAppURL] as? String, let webDownloadAppURL = json[DFJSONKey.webDownloadAppURL] as? String, let updateComment = json[DFJSONKey.updateComment] as? String {
            print(webDownloadAppURL)
            
//            let alert = UIAlertController(title: DFLocalizable.valueOf(.DF_APP_FORCE_UPDATE), message: updateComment, preferredStyle: UIAlertController.Style.alert)
            let alert = UIAlertController(title: "您必須更新App版本才能繼續操作", message: updateComment, preferredStyle: UIAlertController.Style.alert)
            
//            let confirmAction = UIAlertAction(title: DFLocalizable.valueOf(.DF_COMMAND_CONFIRM), style: .default, handler: { (action) in
            let confirmAction = UIAlertAction(title: "確認", style: .default, handler: {
                (action) in
                let url : URL = URL(string: storeAppURL)!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            })

//            let cancelAction = UIAlertAction(title: DFLocalizable.valueOf(.DF_COMMAND_CANCEL), style: .destructive, handler: { (action) in
            let cancelAction = UIAlertAction(title: "取消", style: .destructive, handler: { (action) in
                if self.isModal() {
                    self.dismiss(animated: true, completion: nil)
                }else {
                    self.navigationController?.popViewController(animated: true)
                }
            })

            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            if let vc = DFUtil.getTopVC() {
                vc.present(alert, animated: true, completion: nil)
            }
            DFUtil.forceUpdateFlag = true
        }
    }
    
    //執行送出
    func sendAPI(address: String, parameters: [String: Any]) {
        DFAPI.customPost(address: address, parameters: parameters) { json in
            print(json)
            DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
                DispatchQueue.main.async {
                    self.dfStopActivityIndicator()
                    if let result = json["result"] as? String {
                        if result == "FAIL" {
                            let confirmSheet = UIAlertController(title: "Tips", message: json["msg"] as? String, preferredStyle: .alert)
                            
                            let confirmAction = UIAlertAction(title: "確定", style: .default, handler: {
                                action in
                            })
                            confirmSheet.addAction(confirmAction)
                            self.present(confirmSheet, animated: true, completion: nil)
                        }else {
                            
                            let confirmSheet = UIAlertController(title: "Tips", message: json["msg"] as? String, preferredStyle: .alert)
                            
                            let confirmAction = UIAlertAction(title: "確定", style: .default, handler: {
                                action in
                                if self.isModal() {
                                    self.dismiss(animated: true, completion: nil)
                                }else {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })
                            confirmSheet.addAction(confirmAction)
                            self.present(confirmSheet, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    //設定導覽列button
    func setButtons() {
        for (index, button) in oriFormData!.buttons.enumerated() {
            let buttonItem = UIBarButtonItem(title: button.name, style: UIBarButtonItem.Style.plain, target: self, action: #selector(buttonClick))
            
            buttonItem.tag = index
            if let tokenKey = tokenKey, tokenKey == "mobilefpcToken" {
                buttonItem.tintColor = .white
            }
            self.navigationItem.rightBarButtonItems?.append(buttonItem)
        }
    }
    
    //導覽列按鈕點擊事件
    @objc func buttonClick(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        
        let button = oriFormData?.buttons[sender.tag]
        
        //顯示多選項表單
        if button?.type == "subForm" {
            let actionSheet = UIAlertController(title: button?.actionTip, message: nil, preferredStyle: .actionSheet)
            
            for subButton in button!.actions! {
                let action = UIAlertAction(title: subButton.title, style: .default, handler: {
                    action in
                    self.execAction(type: subButton.actionType!, title: (button?.actionTip)!, urlString: subButton.url!)
                })
                
                actionSheet.addAction(action)
            }
            
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        }else {
            execAction(type: (button?.type)!, title: (button?.actionTip)!, urlString: (button?.url)!)
        }
    }
    
    //依照type執行動作
    /*
     send: 將整個form轉成string後，回傳至後端
     form: 取得下一層form
     link: 打開網頁
     */
    func execAction(type: String, title: String, urlString: String) {
        dfShowActivityIndicator()
        switch type {
        case "send":
            let confirmSheet = UIAlertController(title: "Tips", message: title, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "確定", style: .default, handler: {
                action in
                DFAPI.customPost(address: self.tokenURL!, parameters: [
                    "accessToken": self.accessToken!,
                    "comment" : "DynamicForm"
                ]) { json in
                    print(json)
                    
                    if let data = json[DFJSONKey.data] {
                        
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .millisecondsSince1970
                            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                            
                            let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: DFDisposableToken.self)
                            print(obj)
                            
                            let jsonEncoder = JSONEncoder()
                            let oriJsonData = try jsonEncoder.encode(self.oriFormData)
                            let json = String(data: oriJsonData, encoding: String.Encoding.utf8)
                            
                            let parameters = [
                                "formId": self.oriFormData?.formId ?? "",
                                "formString": json ?? "",
                                self.tokenKey!: obj.accessTokenSHA256
                            ]
                            
                            self.sendAPI(address: urlString, parameters: parameters)
                            
                        } catch {
                            
                        }
                    }
                }
            })
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            action in
                self.dfStopActivityIndicator()
            })
            confirmSheet.addAction(confirmAction)
            confirmSheet.addAction(cancelAction)
            
            self.present(confirmSheet, animated: true, completion: nil)
        case "form":
            let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
            let vc = storyboard.instantiateViewController(withIdentifier: "DFmainVC") as? DFmainVC
            
            vc?.urlString = urlString
            vc?.accessToken = accessToken
            vc?.tokenKey = tokenKey
            vc?.tokenURL = tokenURL
            vc?.isFirstLayer = false
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            if let tokenKey = tokenKey, tokenKey == "mobilefpcToken" {
                backItem.tintColor = .white
            }
            
            self.navigationItem.backBarButtonItem = backItem
            self.navigationController?.pushViewController(vc!, animated: true)
        case "link":
            if #available(iOS 9.0, *) {
                if let url = URL(string: urlString) {
                    let svc = SFSafariViewController(url: url)
                    self.present(svc, animated: true, completion: nil)
                }
            } else {
                if let url = URL(string: urlString) {
                    UIApplication.shared.openURL(url)
                }
            }
        default:
            break
        }
    }
    
    //清空formData List
    func clear() {
        self.navigationItem.rightBarButtonItems = []
        formDataList = [FormData]()
        for i in 0..<(oriFormData?.cells.count)! {
            let formData = oriFormData?.cells[i]
            formData?.inputValue = nil
        }
    }
    
    //設定表單UI資料，須記錄每個cell的index
    func setFormData() {
        formDataList = [FormData]()
        for (index, formData) in oriFormData!.cells.enumerated() {
            let data = FormData()
            
            data.formNumber = index
            data.title = formData.title
            data.formType = formData.type
            data.formId = formData.id
            data.keyValueArray = formData.keyValueArray
            data.inputValue = formData.textValue
            data.optionValue = formData.choiceValue
            data.dynamicField = formData.dynamicField
            data.isReadOnly = formData.isReadOnly
            data.isRequired = formData.isRequired
            data.actionTip = formData.actionTip
            data.actions = formData.actions
            
            data.fileList = formData.fileList
            
            switch formData.type {
            case "radio", "checkbox":
                data.title = formData.title
                data.formType = "label"
                formDataList.append(data)
                
                for (optionIndex, radioOption) in formData.options!.enumerated() {
                    let option = FormData()
                    option.formNumber = index
                    option.optionNumber = optionIndex
                    option.title = radioOption.name
                    option.formType = formData.type
                    option.isReadOnly = formData.isReadOnly
                    
                    for choice in formData.choiceValue! {
                        print("\(radioOption) \(choice) \(optionIndex)")
                        if choice == optionIndex {
                            option.isCheck = true
                            break
                        }
                    }
                    
                    formDataList.append(option)
                }
            case "attachment":
                for attachment in formData.fileList! {
                    let attachmentData = FormData()
                    attachmentData.title = attachment.title
                    attachmentData.formType = attachment.type
                    attachmentData.isReadOnly = formData.isReadOnly
                    attachmentData.fileUrl = attachment.url
                    formDataList.append(attachmentData)
                }
            case "picture":
                for picture in formData.fileList! {
                    let pictureData = FormData()
                    pictureData.title = picture.title
                    pictureData.formType = picture.type
                    pictureData.formId = formData.id
                    pictureData.isReadOnly = formData.isReadOnly
                    let imageUrlString = picture.url
                    let imageUrl: URL = URL(string: imageUrlString!)!
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData:NSData = NSData(contentsOf: imageUrl) {
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData as Data){
                                    pictureData.image = image
                                }
                            }
                        }
                    }
                    
                    formDataList.append(pictureData)
                }
            case "dynamicTextField":
                formDataList.append(data)
                setDynamicInputData(formData: formData, index: index, formType: "textField")
                
            case "dynamicTextArea":
                formDataList.append(data)
                setDynamicInputData(formData: formData, index: index, formType: "textArea")
                
            case "singleSelection", "multipleSelection":
                formDataList.append(data)
                
            case "upload":
                formDataList.append(data)
                setFileData(formData: formData, index: index)
                
            case "sign":
                if !formData.fileList!.isEmpty {
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData:NSData = NSData(contentsOf: URL(string: formData.fileList![0].url!)!) {
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData as Data){
                                    data.image = image
                                }
                            }
                        }
                    }
                }
                
                formDataList.append(data)
            default:
                formDataList.append(data)
            }
        }
    }
    
    //設定動態列表資料
    func setDynamicInputData(formData: cell, index: Int, formType: String) {
        for i in 0..<formData.count! {
            let inputField = FormData()
            inputField.formNumber = index
            inputField.inputNumber = i
            inputField.formType = formType
            inputField.mainType = formData.type
            inputField.isReadOnly = formData.isReadOnly
            
            formDataList.append(inputField)
        }
    }
    
    //設定附件/照片資料
    func setFileData(formData: cell, index: Int) {
        if let fileList = formData.fileList {
            for i in 0..<fileList.count {
                let file = fileList[i]
                if file.type == "picture" {
                    insertPicture(index: index, title: file.title!, mainType: formData.type!, inputNumber: i, isReadOnly: formData.isReadOnly!, imageUrlString: file.url!)
                }else if file.type == "attachment" {
                    let attachmentData = FormData()
                    attachmentData.formNumber = index
                    attachmentData.inputNumber = i
                    attachmentData.title = file.title
                    attachmentData.formType = "attachment"
                    attachmentData.mainType = formData.type
                    attachmentData.formId = "\(i)"
                    attachmentData.isReadOnly = formData.isReadOnly
                    attachmentData.fileUrl = file.url
                    
                    formDataList.append(attachmentData)
                }
                
            }
        }
    }
    
    //新增照片資料
    func insertPicture(index: Int, title: String, mainType: String, inputNumber: Int, isReadOnly: Bool, imageUrlString: String) {
        let pictureData = FormData()
        pictureData.formNumber = index
        pictureData.title = title
        pictureData.inputNumber = inputNumber
        pictureData.formType = "picture"
        pictureData.mainType = mainType
        pictureData.formId = "\(inputNumber)"
        pictureData.isReadOnly = isReadOnly
        
        let imageUrl: URL = URL(string: imageUrlString)!
        print(imageUrl)
        print("test")
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageData:NSData = NSData(contentsOf: imageUrl) {
                DispatchQueue.main.async {
                    if let image = UIImage(data: imageData as Data){
                        pictureData.image = image
                    }
                }
            }
        }
        
        formDataList.append(pictureData)
    }
    
    //動態列表刪除動作
    @objc func deleteTapped(sender:UITapGestureRecognizer) {
        let tagInt = sender.view?.tag
        self.oriFormData?.cells[tagInt!].dynamicField?.remove(at: sender.inputNumber)
        self.oriFormData?.cells[tagInt!].count = (self.oriFormData?.cells[tagInt!].count)! - 1
        var newIndex = 0
        
        for (index, formData) in formDataList.enumerated() {
            if formData.formType == "textField" {
                if formData.mainType == "dynamicTextField", tagInt == formData.formNumber, sender.inputNumber == formData.inputNumber {
                    formDataList.remove(at: index)
                    break
                }
            }else if formData.formType == "textArea" {
                if formData.mainType == "dynamicTextArea", tagInt == formData.formNumber, sender.inputNumber == formData.inputNumber {
                    formDataList.remove(at: index)
                    break
                }
            }
        }
        
        for formData in formDataList {
            if formData.formType == "textField" {
                if formData.mainType == "dynamicTextField", tagInt == formData.formNumber {
                    if newIndex > (self.oriFormData?.cells[tagInt!].count)! {
                        break
                    }
                    formData.inputNumber = newIndex
                    newIndex += 1
                }
            }else if formData.formType == "textArea" {
                if formData.mainType == "dynamicTextArea", tagInt == formData.formNumber {
                    if newIndex > (self.oriFormData?.cells[tagInt!].count)! {
                        break
                    }
                    formData.inputNumber = newIndex
                    newIndex += 1
                }
            }
        }
        
        tableView.reloadData()
    }
    
    //附件/照片刪除動作
    @objc func deleteFileTapped(sender:UITapGestureRecognizer) {
        let tagInt = sender.view?.tag
        
        self.oriFormData?.cells[tagInt!].fileList?.remove(at: sender.inputNumber)
        var newIndex = 0
        
        for (index, formData) in formDataList.enumerated() {
            if formData.formType == "picture" {
                if formData.mainType == "upload", tagInt == formData.formNumber, sender.inputNumber == formData.inputNumber {
                    formDataList.remove(at: index)
                    break
                }
            }else if formData.formType == "attachment" {
                if formData.mainType == "upload", tagInt == formData.formNumber, sender.inputNumber == formData.inputNumber {
                    formDataList.remove(at: index)
                    break
                }
            }
        }
        
        
        for formData in formDataList {
            if formData.formType == "picture" {
                if formData.mainType == "upload", tagInt! == formData.formNumber {
                    if newIndex > (self.oriFormData?.cells[formData.formNumber!].fileList?.count)! {
                        break
                    }
                    formData.inputNumber = newIndex
                    newIndex += 1
                }
            }else if formData.formType == "attachment" {
                if formData.mainType == "upload", tagInt == formData.formNumber {
                    if newIndex > (self.oriFormData?.cells[tagInt!].fileList?.count)! {
                        break
                    }
                    formData.inputNumber = newIndex
                    newIndex += 1
                }
            }
        }
        tableView.reloadData()
    }
    
    //設定字型
    func setFont(cell: FormTextFieldCell, formNumber: Int, formData: FormData) {
        if let fontSize = oriFormData?.cells[formNumber].titleFont?.size {
            cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
//            cell.constraint?.constant = CGFloat(fontSize)
        }
        
        if let fontColor = oriFormData?.cells[formNumber].titleFont?.color {
            cell.title.textColor = UIColor(hexString: fontColor)
        }
        
        if let title = formData.title, title != "" {
            cell.title.text = title
//            cell.topConstraint.constant = 10
        }
//        else {
//            cell.topConstraint.constant = 0
//            cell.constraint?.constant = 0
//        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formDataList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: FormTitleCell = tableView.dequeueReusableCell(withIdentifier: "FormTitleCell", for: indexPath) as! FormTitleCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let formData = formDataList[indexPath.row]
        let formNumber = formData.formNumber
        
        switch formData.formType {
        case "label":
            
            if let fontSize = oriFormData?.cells[formNumber!].titleFont?.size {
                cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let fontColor = oriFormData?.cells[formNumber!].titleFont?.color {
                cell.title.textColor = UIColor(hexString: fontColor)
            }
            
            if let required = oriFormData?.cells[formNumber!].isRequired {
                cell.requireLabel.isHidden = !required
            }
            
            cell.title.text = formData.title
            return cell
        case "textField":
            //輸入列與動態輸入列的產生
            
            let cell: FormTextFieldCell = tableView.dequeueReusableCell(withIdentifier: "FormTextFieldCell", for: indexPath) as! FormTextFieldCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.inputField.placeholder = ""
            cell.inputField.keyboardType = UIKeyboardType.default
            
            setFont(cell: cell, formNumber: formNumber!, formData: formData)
            
            if let isReadOnly = formData.isReadOnly {
                if isReadOnly {
                    cell.isUserInteractionEnabled = false
                }else {
                    cell.isUserInteractionEnabled = true
                }
            }
            
            if let inputConfig = oriFormData?.cells[formNumber!].inputConfig {
                if let placeholder = inputConfig.placeholder {
                    cell.inputField.placeholder = placeholder
                }
                
                if let type = inputConfig.type {
                    if type == "number" {
                        cell.inputField.keyboardType = UIKeyboardType.decimalPad
                    }
                }
            }
            
            if oriFormData?.cells[formNumber!].textValue == nil {
                cell.inputField.text = ""
            }
            cell.inputField.delegate = self
            cell.inputField.tag = formNumber!
            
            //若為動態輸入列，則可以刪除
            if formData.mainType == "dynamicTextField" {
                let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteTapped))
                
                deleteRecognizer.inputNumber = formData.inputNumber!
                cell.deleteIcon.addGestureRecognizer(deleteRecognizer)
                cell.deleteIcon.isHidden = false
                cell.imageConstraint?.constant = 25
                cell.deleteIcon.tag = formNumber!
                
                cell.inputField.inputNumber = formData.inputNumber!
                for (index, input) in (oriFormData?.cells[formNumber!].dynamicField)!.enumerated() {
                    
                    if formData.inputNumber == index {
                        cell.inputField.text = input.name
                        continue
                    }
                }
            }else {
                cell.deleteIcon.isHidden = true
                cell.imageConstraint?.constant = 0
                cell.inputField.text = formData.inputValue
            }
            
            cell.inputField.inputView = .none
            cell.inputField.inputAccessoryView = .none
            return cell
        case "textArea":
            //輸入框與動態輸入框的產生
            
            let cell: FormTextAreaCell = tableView.dequeueReusableCell(withIdentifier: "FormTextAreaCell", for: indexPath) as! FormTextAreaCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            
            if let fontSize = oriFormData?.cells[formNumber!].titleFont?.size {
                cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let fontColor = oriFormData?.cells[formNumber!].titleFont?.color {
                cell.title.textColor = UIColor(hexString: fontColor)
            }
            
            if let isReadOnly = formData.isReadOnly {
                if isReadOnly {
                    cell.isUserInteractionEnabled = false
                }else {
                    cell.isUserInteractionEnabled = true
                }
            }
            
            if let title = formData.title, title != "" {
                cell.title.text = title
//                cell.topConstraint.constant = 10
            }
//            else {
//                cell.topConstraint.constant = 0
//                cell.constraint?.constant = 0
//            }
            
            if oriFormData?.cells[formNumber!].textValue == nil {
                cell.formTextArea.text = ""
            }
            cell.formTextArea.delegate = self
            cell.formTextArea.layer.borderWidth = 1.0
            cell.formTextArea.layer.borderColor = UIColor.lightGray.cgColor
            cell.formTextArea.layer.cornerRadius = 5.0
            cell.formTextArea.tag = formNumber!
            
            //若為動態輸入列，則可以刪除
            if formData.mainType == "dynamicTextArea" {
                let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteTapped))
                
                deleteRecognizer.inputNumber = formData.inputNumber!
                cell.deleteIcon.addGestureRecognizer(deleteRecognizer)
                cell.deleteIcon.isHidden = false
                cell.imageConstraint?.constant = 25
                cell.deleteIcon.tag = formNumber!
                
                cell.formTextArea.inputNumber = formData.inputNumber!
                for (index, input) in (oriFormData?.cells[formNumber!].dynamicField)!.enumerated() {
                    
                    if formData.inputNumber == index {
                        cell.formTextArea.text = input.name
                        continue
                    }
                }
            }else {
                cell.deleteIcon.isHidden = true
                cell.imageConstraint?.constant = 0
                cell.formTextArea.text = formData.inputValue
            }
            
            return cell
        case "radio":
            let cell: FormChoiceCell = tableView.dequeueReusableCell(withIdentifier: "FormChoiceCell", for: indexPath) as! FormChoiceCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if formData.isCheck == false {
                cell.checkIcon.image = UIImage(named: "df_icon_single_selection_unchecked", in: bundle, compatibleWith: nil)
            } else {
                cell.checkIcon.image = UIImage(named: "df_icon_single_selection_checked", in: bundle, compatibleWith: nil)
            }
            
            cell.option.text = formData.title
            return cell
        case "checkbox":
            let cell: FormChoiceCell = tableView.dequeueReusableCell(withIdentifier: "FormChoiceCell", for: indexPath) as! FormChoiceCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if formData.isCheck == false {
                cell.checkIcon.image = UIImage(named: "df_icon_multiple_selection_unchecked", in: bundle, compatibleWith: nil)
            } else {
                cell.checkIcon.image = UIImage(named: "df_icon_multiple_selection_checked", in: bundle, compatibleWith: nil)
            }
            
            cell.option.text = formData.title
            return cell
        case "date":
            let cell: FormTextFieldCell = tableView.dequeueReusableCell(withIdentifier: "FormTextFieldCell", for: indexPath) as! FormTextFieldCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            setDateCell(formData: formData, type: "date", format: "yyyy-MM-dd", formNumber: formNumber!, cell: cell)
            
            return cell
        case "time":
            let cell: FormTextFieldCell = tableView.dequeueReusableCell(withIdentifier: "FormTextFieldCell", for: indexPath) as! FormTextFieldCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            setDateCell(formData: formData, type: "time", format: "HH:mm", formNumber: formNumber!, cell: cell)
            
            return cell
        case "dateTime":
            let cell: FormTextFieldCell = tableView.dequeueReusableCell(withIdentifier: "FormTextFieldCell", for: indexPath) as! FormTextFieldCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            setDateCell(formData: formData, type: "dateTime", format: "yyyy-MM-dd HH:mm", formNumber: formNumber!, cell: cell)
            
            return cell
        case "keyValue":
            
            let cell: KeyValueCell = tableView.dequeueReusableCell(withIdentifier: "KeyValueCell", for: indexPath) as! KeyValueCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            DFUtil.setKeyValueData(cell: cell, keyValueArray: formData.keyValueArray!)
            
            return cell
            
        case "attachment":
            let cell: fileCell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! fileCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.fileName.text = formData.title
            cell.deleteIcon.isHidden = true
            
            if formData.mainType == "upload" {
                if formData.isReadOnly! {
                    cell.deleteIcon.isHidden = true
                }else {
                    cell.deleteIcon.isHidden = false
                }
                
                let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteFileTapped))
                
                deleteRecognizer.inputNumber = formData.inputNumber!
                cell.deleteIcon.addGestureRecognizer(deleteRecognizer)
                
                cell.deleteIcon.tag = formNumber!
                
                
            }
            
            if formData.title!.contains(".pdf"){
                cell.imageIcon.image = UIImage(named: "df_new_pdf.png", in: bundle, compatibleWith: nil)
            }else if formData.title!.contains(".doc") || formData.title!.contains(".docx") {
                cell.imageIcon.image = UIImage(named: "df_new_doc.png", in: bundle, compatibleWith: nil)
            }else if formData.title!.contains(".xlsx") || formData.title!.contains(".xls") {
                cell.imageIcon.image = UIImage(named: "df_new_xls.png", in: bundle, compatibleWith: nil)
            }else if formData.title!.contains(".ppt") || formData.title!.contains(".pptx") {
                cell.imageIcon.image = UIImage(named: "df_new_ppt.png", in: bundle, compatibleWith: nil)
            }
            return cell
        case "picture":
            let cell: fileCell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! fileCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.imageIcon.image = formData.image
            cell.fileName.text = formData.title
            cell.deleteIcon.isHidden = true
            
            
            if formData.mainType == "upload" {
                if formData.isReadOnly! {
                    cell.deleteIcon.isHidden = true
                }else {
                    cell.deleteIcon.isHidden = false
                }
                
                let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteFileTapped))
                
                deleteRecognizer.inputNumber = formData.inputNumber!
                cell.deleteIcon.addGestureRecognizer(deleteRecognizer)
                
                cell.deleteIcon.tag = formNumber!
            }
            
            return cell
        case "dynamicTextField", "dynamicTextArea":
            let cell: DynamicFieldCell = tableView.dequeueReusableCell(withIdentifier: "DynamicFieldCell", for: indexPath) as! DynamicFieldCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if let fontSize = oriFormData?.cells[formNumber!].titleFont?.size {
                cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let fontColor = oriFormData?.cells[formNumber!].titleFont?.color {
                cell.title.textColor = UIColor(hexString: fontColor)
            }
            
            cell.title.text = formData.title
            
            return cell
        case "singleSelection", "multipleSelection":
            let cell: SingleSelectionCell = tableView.dequeueReusableCell(withIdentifier: "SingleSelectionCell", for: indexPath) as! SingleSelectionCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.actionTip.text = formData.title
            
            if let fontSize = oriFormData?.cells[formNumber!].titleFont?.size {
                cell.actionTip.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let fontColor = oriFormData?.cells[formNumber!].titleFont?.color {
                cell.actionTip.textColor = UIColor(hexString: fontColor)
            }
            
            cell.optionTitle.text = ""
            
            if formData.dynamicField!.count > 0 {
                cell.optionTitle.text = ""
                var inputText = ""
                
                for (index, input) in (formData.dynamicField?.enumerated())! {
                    if index != formData.dynamicField!.count - 1 {
                        inputText += input.name! + ", "
                        
                    }else {
                        inputText += input.name!
                    }
                }
                
                
                cell.optionTitle.text = inputText
            }
            
            return cell
        case "upload":
            let cell: UploadCell = tableView.dequeueReusableCell(withIdentifier: "UploadCell", for: indexPath) as! UploadCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.title.text = formData.title
            
            return cell
        case "sign":
            let cell: DFSignCell = tableView.dequeueReusableCell(withIdentifier: "DFSignCell", for: indexPath) as! DFSignCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.title.text = formData.title
            
            if let image = formData.image {
                cell.signImageView.image = image
            }
            
            
            return cell
        default:
            return cell
        }
    }
    
    @objc func doneButtonTapped(sender: UIBarButtonItem) {
        // 依據元件的 tag 取得 UITextField
        print(sender.tag)
        for dateFormatter in dateFormatterList {
            if dateFormatter.index == sender.tag {
                let timeInterval:TimeInterval = (dateFormatter.datePicker?.date.timeIntervalSince1970)!
                print(timeInterval)
                self.oriFormData?.cells[sender.tag].textValue = String(dateFormatter.datePicker!.date.timeIntervalSince1970 * 1000).components(separatedBy: ".").first
            }
        }
        
        for formData in formDataList {
            if sender.tag == formData.formNumber {
                formData.inputValue = self.oriFormData?.cells[sender.tag].textValue
            }
        }
        self.tableView.reloadData()
        self.view.endEditing(true)
    }
    
    func setDateCell(formData: FormData, type: String, format: String, formNumber: Int, cell: FormTextFieldCell) {
        if formData.isReadOnly! {
            cell.inputField.isUserInteractionEnabled = false
        }else {
            cell.inputField.isUserInteractionEnabled = true
        }
        
        if let inputConfig = oriFormData?.cells[formNumber].inputConfig {
            if let placeholder = inputConfig.placeholder {
                cell.inputField.placeholder = placeholder
            }
        }
        
        setFont(cell: cell, formNumber: formNumber, formData: formData)
        setDatePicker(type: type, formNumber: formNumber, cell: cell)
        
        
        cell.inputField.text = ""
        cell.inputField.tag = formNumber
        if formData.inputValue != "" {
            cell.inputField.text = setTimestampToDate(timestampString: formData.inputValue!, format: format)
        }
        
        cell.deleteIcon.isHidden = true
    }
    
    //設定date, time, dateTime
    func setDatePicker(type: String, formNumber: Int, cell: FormTextFieldCell) {
        let toolBar = UIToolbar()
        let formatter = DateFormatter()
        let datePicker:UIDatePicker = UIDatePicker()
        
        if type == "date" {
            formatter.dateFormat = "yyyy-MM-dd"
            datePicker.datePickerMode = .date
        }else if type == "time" {
            formatter.dateFormat = "HH:mm"
            datePicker.datePickerMode = .time
        }else if type == "dateTime" {
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            datePicker.datePickerMode = .dateAndTime
        }
        
        
        datePicker.date = NSDate() as Date
        
        toolBar.sizeToFit()
        
        let dateFormatter = dateFormatterObj()
        dateFormatter.index = formNumber
        dateFormatter.dateFormatter = formatter
        dateFormatter.datePicker = datePicker
        dateFormatterList.append(dateFormatter)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        toolBar.setItems([doneButton], animated: true)
        
        doneButton.tag = formNumber
        
        cell.inputField.inputView = datePicker
        cell.inputField.inputAccessoryView = toolBar
    }
    
    func setTimestampToDate(timestampString: String, format: String) -> String{
        let timestamp = Int(timestampString)!
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let formData = formDataList[indexPath.row]
        
        if formData.formType != "picture" , formData.formType != "attachment" {
            if formData.isReadOnly! {
                return
            }
        }
        
        
        if let actions = formData.actions, actions.count > 0 {
            let action = formData.actions![0]
            execAction(type: action.actionType!, title: action.title!, urlString: action.url!)
        }
        
        switch formData.formType {
        case "radio":
            for data in formDataList {
                if formData.formNumber == data.formNumber {
                    data.isCheck = false
                }
            }
            
            self.oriFormData?.cells[formData.formNumber!].choiceValue?.removeAll()
            self.oriFormData?.cells[formData.formNumber!].choiceValue?.append(formData.optionNumber!)
            formData.isCheck = true
            
            tableView.reloadData()
        case "checkbox":
            
            if formData.isCheck {
                self.oriFormData?.cells[formData.formNumber!].choiceValue = self.oriFormData?.cells[formData.formNumber!].choiceValue?.filter({$0 != formData.optionNumber})
            }else {
                self.oriFormData?.cells[formData.formNumber!].choiceValue?.append(formData.optionNumber!)
            }
            
            formData.isCheck = !formData.isCheck
            
            self.oriFormData?.cells[formData.formNumber!].choiceValue = self.oriFormData?.cells[formData.formNumber!].choiceValue?.sorted(by: {$0 < $1})
            
            tableView.reloadData()
        case "picture":
            let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
            let imageVC = storyboard.instantiateViewController(withIdentifier: "DFImageVC") as? DFImageVC
            
            var index = 0
            var finalIndex = 0
            for imageFormData in formDataList {
                if imageFormData.formType == "picture" {
                    if let image = imageFormData.image{
                        imageVC!.images.append(image)
                        if imageFormData.formId == formData.formId && imageFormData.formNumber == formData.formNumber {
                            finalIndex = index
                        }
                        index += 1
                    }
                }
            }
            
            imageVC?.imageIndex = finalIndex
            
            present(imageVC!, animated: true)
                break
        case "attachment":
            if #available(iOS 9.0, *) {
                if let url = URL(string: formData.fileUrl!) {
                    let svc = SFSafariViewController(url: url)
                    self.present(svc, animated: true, completion: nil)
                }
            } else {
                if let url = URL(string: formData.fileUrl!) {
                    UIApplication.shared.openURL(url)
                }
            }
        case "dynamicTextField":
            setInputView(formData: formData, formType: "textField")
        case "dynamicTextArea":
            setInputView(formData: formData, formType: "textArea")
        case "singleSelection":
            let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
            let vc = storyboard.instantiateViewController(withIdentifier: "DFSelectionVC") as? DFSelectionVC
            
            var optionList = [DynamicInput]()
            
            if let actions = self.oriFormData?.cells[formData.formNumber!].actions {
                if actions.count > 0{
                    vc?.urlString = self.oriFormData?.cells[formData.formNumber!].actions![0].url
                }
            }
            
            if let oriOptionList = self.oriFormData?.cells[formData.formNumber!].options, oriOptionList.count > 0 {
                for option in oriOptionList {
                    let dynamicInput = DynamicInput()
                    
                    var item1 = keyValue()
                    
                    item1.title = option.name
                    dynamicInput.id = option.id
                    dynamicInput.isSelected = false
                    dynamicInput.name = option.name
                    dynamicInput.keyValueArray!.append(item1)
                    dynamicInput.keyValueArray!.append(keyValue())
                    dynamicInput.keyValueArray!.append(keyValue())
                    dynamicInput.keyValueArray!.append(keyValue())
                    
                    optionList.append(dynamicInput)
                }
            }
            
            if !optionList.isEmpty {
                vc?.isFilter = true
            }
            
            vc?.type = formData.formType
            vc?.id = (self.oriFormData?.cells[formData.formNumber!].id)!
            vc?.oriOptionList = optionList
            vc?.optionList = optionList
            vc?.accessToken = accessToken
            vc?.tokenKey = tokenKey
            vc?.tokenURL = tokenURL
            
            let backItem = UIBarButtonItem()
            if let tokenKey = tokenKey, tokenKey == "mobilefpcToken" {
                backItem.tintColor = .white
            }
            backItem.title = "Back"
            self.navigationItem.backBarButtonItem = backItem
            self.navigationController?.pushViewController(vc!, animated: true)
            
        case "multipleSelection":
            let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
            let vc = storyboard.instantiateViewController(withIdentifier: "DFSelectionVC") as? DFSelectionVC
            
            var optionList = [DynamicInput]()
            
            if let actions = self.oriFormData?.cells[formData.formNumber!].actions {
                if actions.count > 0{
                    vc?.urlString = self.oriFormData?.cells[formData.formNumber!].actions![0].url
                }
            }
            
            if let oriOptionList = self.oriFormData?.cells[formData.formNumber!].options {
                for option in oriOptionList {
                    let dynamicInput = DynamicInput()
                    var item1 = keyValue()
                    
                    item1.title = option.name
                    dynamicInput.id = option.id
                    dynamicInput.isSelected = false
                    
                    dynamicInput.keyValueArray!.append(item1)
                    dynamicInput.keyValueArray!.append(keyValue())
                    dynamicInput.keyValueArray!.append(keyValue())
                    dynamicInput.keyValueArray!.append(keyValue())
                    
                    optionList.append(dynamicInput)
                }
            }
            
            if let oriOptionList = self.oriFormData?.cells[formData.formNumber!].dynamicField {
                vc?.chosenItemList = oriOptionList
            }
            
            if !optionList.isEmpty {
                vc?.isFilter = true
            }
            
            vc?.type = formData.formType
            vc?.id = (self.oriFormData?.cells[formData.formNumber!].id)!
            vc?.oriOptionList = optionList
            vc?.optionList = optionList
            vc?.accessToken = accessToken
            vc?.tokenKey = tokenKey
            vc?.tokenURL = tokenURL
            
            let backItem = UIBarButtonItem()
            if let tokenKey = tokenKey, tokenKey == "mobilefpcToken" {
                backItem.tintColor = .white
            }
            backItem.title = "Back"
            self.navigationItem.backBarButtonItem = backItem
            self.navigationController?.pushViewController(vc!, animated: true)
        case "upload":
            
            let picker = UIImagePickerController()
            picker.delegate = self
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            //檢查裝置是否有相機功能
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraAction = UIAlertAction(title: "拍攝照片", style: .default) { action in
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                    picker.formNumber = formData.formNumber!
                    self.present(picker, animated: true, completion: nil)
                }
                actionSheet.addAction(cameraAction)
            }
            // 開啟相簿
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let photoAction = UIAlertAction(title: "從相簿挑選照片", style: .default) { action in
                    picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    picker.allowsEditing = false // 可對照片作編輯
                    picker.delegate = self
                    picker.formNumber = formData.formNumber!
                    self.present(picker, animated: true, completion: nil)
                }
                actionSheet.addAction(photoAction)
            }
            
            let uploadFileAction = UIAlertAction(title: "上傳檔案", style: .default) { action in
                let importMenu = UIDocumentMenuViewController(documentTypes: [
                    kUTTypePDF as String, kUTTypeBMP as String, kUTTypePNG as String, kUTTypeJPEG as String, kUTTypeGIF as String, "com.microsoft.word.doc", "com.microsoft.excel.xls",
                    "com.microsoft.powerpoint.ppt", "org.openxmlformats.wordprocessingml.document",
                    "org.openxmlformats.spreadsheetml.sheet", "org.openxmlformats.presentationml.presentation", kUTTypePlainText as String], in: .import)
                importMenu.delegate = self
                importMenu.formNumber = formData.formNumber!
                
                // For iPad2 crash bug
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    let rectOfCellInTableView = tableView.rectForRow(at: indexPath)
                    let rectOfCellInSuperview = tableView.convert(rectOfCellInTableView, to: tableView.superview)
                    print("X of Cell is: \(rectOfCellInSuperview.origin.x)")
                    print("Y of Cell is: \(rectOfCellInSuperview.origin.y)")
                    
                    actionSheet.popoverPresentationController!.sourceView = self.view
                    actionSheet.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width - 50, y: rectOfCellInSuperview.origin.y + rectOfCellInSuperview.height/2.0, width: 1.0, height: 1.0)
                }
                self.present(importMenu, animated: true) {
                    print("option menu presented")
                }
                
            }
            
            actionSheet.addAction(uploadFileAction)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel)
            
            actionSheet.addAction(cancelAction)
            
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                actionSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
                actionSheet.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
                actionSheet.popoverPresentationController?.sourceView = self.view
                actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            }
            self.present(actionSheet, animated: true) {
                print("option menu presented")
            }
            
        case "sign":
            let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
            let vc = storyboard.instantiateViewController(withIdentifier: "DFElecSignVC") as? DFElecSignVC
            
            vc?.index = formData.formNumber ?? -1
            
            let backItem = UIBarButtonItem()
            if let tokenKey = tokenKey, tokenKey == "mobilefpcToken" {
                backItem.tintColor = .white
            }
            
            backItem.title = "Back"
            self.navigationItem.backBarButtonItem = backItem
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            tableView.reloadData()
        }
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = (info[UIImagePickerController.InfoKey.editedImage] ?? info[UIImagePickerController.InfoKey.originalImage]) as? UIImage {
            let imageName = UUID().uuidString + ".jpg"
            
            dfShowActivityIndicator()
            customUpload(oriImage: image, fileUrl: nil, fileName: imageName, formNumber: picker.formNumber, type: "picture")
            
        }
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.formNumber = documentMenu.formNumber
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    //選擇檔案後上傳
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        dfShowActivityIndicator()
        customUpload(oriImage: nil, fileUrl: url, fileName: url.lastPathComponent, formNumber: controller.formNumber, type: "attachment")
    }
    
    func customUpload(oriImage: UIImage?, fileUrl: URL?, fileName: String, formNumber: Int, type: String) {
        
        //分隔線
        let boundary = "Boundary-\(UUID().uuidString)"
        
        let url = URL(string: DFAPI.fileUploadUrl)!
        var request = URLRequest(url: url)
        //請求類型為POST
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type")
        
        //傳遞的參數
        let parameters = [
            "file": "file",
        ]
        
        //傳遞的文件
        if let image = oriImage{
            if let compressImage = image.jpegData(compressionQuality: 0.5) {
                //                multipartFormData.append(compressImage, withName: "file", fileName: fileName, mimeType: "image/jpeg")
                //創建表單body
                request.httpBody = try! createBody(with: parameters, data: compressImage, mimeType: "image/jpeg", filename: fileName, boundary: boundary)
            }
        }else if let url = fileUrl {
            do {
                let data = try Data(contentsOf: url)
                request.httpBody = try! createBody(with: parameters, data: data, mimeType: url.pathExtension, filename: fileName, boundary: boundary)
            }catch {
                
            }
        }
        
        //創建一個表單上傳任務
        let session = URLSession.shared
        let uploadTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            //上傳完畢後
            if error != nil{
                print(error!)
            }else{
                let str = String(data: data!, encoding: String.Encoding.utf8)
                let json = DFAPI.convertToDictionary(text: str!)
                
                if let result = json!["result"] as? String{
                    if result == "SUCCESS" {
                        
                        if let data = json!["data"] as? [String: Any]{
                            
                            print(data)
                            var fileData = file()
                            fileData.title = (data["originalname"] as! String)
                            fileData.type = type
                            fileData.url = (data["fileurl"] as! String)
                            
                            self.oriFormData?.cells[formNumber].fileList?.append(fileData)
                            
                            for (index, file) in self.formDataList.enumerated() {
                                if formNumber == file.formNumber {
                                    let fileData = FormData()
                                    fileData.formNumber = formNumber
                                    fileData.title = fileName
                                    fileData.inputNumber = (self.oriFormData?.cells[formNumber].fileList!.count)! - 1
                                    fileData.formType = type
                                    fileData.mainType = "upload"
                                    fileData.formId = "\((self.oriFormData?.cells[formNumber].fileList!.count)! - 1)"
                                    fileData.image = oriImage
                                    fileData.fileUrl = (data["fileurl"] as! String)
                                    fileData.isReadOnly = false
                                    self.formDataList.insert(fileData, at: index + (self.oriFormData?.cells[formNumber].fileList?.count)!)
                                    break
                                }
                            }
                            DispatchQueue.main.async {
                                self.dfStopActivityIndicator()
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        })
        
        //使用resume方法啟動任務
        uploadTask.resume()
    }
    
    private func createBody(with parameters: [String: String]?,
                            data: Data,
                            mimeType: String,
                            filename: String,
                            boundary: String) throws -> Data {
        var body = Data()
        
        //添加普通參數數據
        if parameters != nil {
            for (key, value) in parameters! {
                // 數據之前要用 --分隔線 來隔開 ，否則後台會解析失敗
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        // 數據之前要用 --分隔線 來隔開 ，否則後台會解析失敗
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; "
            + "name=\"file\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n") //文件類型
        body.append(data) //文件主體
        body.append("\r\n") //使用\r\n來表示這個這個值的結束符
        
        // --分隔線-- 為整個表單的結束符
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    //新增動態列表
    func setInputView(formData: FormData, formType: String) {
        var scrollIndex = 0
        
        for (index, data) in formDataList.enumerated() {
            if formData.formNumber! == data.formNumber {
                let inputField = FormData()
                inputField.formNumber = formData.formNumber!
                inputField.inputNumber = self.oriFormData?.cells[formData.formNumber!].count
                inputField.formType = formType
                inputField.mainType = formData.formType
                inputField.isReadOnly = false
                scrollIndex = index + (self.oriFormData?.cells[formData.formNumber!].count)! + 1
                formDataList.insert(inputField, at: scrollIndex)
                break
            }
        }
        let dynamicValue = DynamicInput()
        dynamicValue.id = UUID().uuidString
        dynamicValue.name = ""
        self.oriFormData?.cells[formData.formNumber!].dynamicField?.append(dynamicValue)
        self.oriFormData?.cells[formData.formNumber!].count = (self.oriFormData?.cells[formData.formNumber!].count)! + 1
        
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: scrollIndex, section: 0), at: .bottom, animated: true)
    }
    
    
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    //隱藏虛擬鍵盤:點擊任意背景時關閉
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    //監聽鍵盤出現時 暫時調整畫面
    override public func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    //鍵盤出現時 縮短畫面
    @objc func keyboardWillShow(_ notification: Foundation.Notification) {
        keyboardPresented = true
        
        let info:NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight: CGFloat = keyboardSize.height
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions(rawValue: 7), animations: {
            self.view.frame = CGRect(x: 0, y: (self.view.frame.origin.y), width: self.view.bounds.width, height: self.screenHeight - keyboardHeight)
            
            self.view.layoutIfNeeded() // Key point!
            
        }) {
            finished -> Void in
            
        }
    }
    
    //鍵盤消失時 恢復畫面
    @objc func keyboardWillHide(_ notification: Foundation.Notification) {
        keyboardPresented = false
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions(rawValue: 7), animations: {
            self.view.frame = CGRect(x: 0, y: (self.view.frame.origin.y), width: self.view.bounds.width, height: self.screenHeight)
            
        }, completion: nil)
    }
    
    //隱藏鍵盤
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let tagInt = textField.tag
        
        for formData in formDataList {
            if formData.formType == "textField" {
                if formData.mainType == "dynamicTextField", tagInt == formData.formNumber {
                    formData.inputValue = textField.text!
                    self.oriFormData?.cells[tagInt].dynamicField?[textField.inputNumber].name = textField.text!
                }else {
                    if tagInt == formData.formNumber {
                        formData.inputValue = textField.text!
                        self.oriFormData?.cells[tagInt].textValue = textField.text!
                    }
                }
            }
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let tagInt = textView.tag
        
        for formData in formDataList {
            if formData.formType == "textArea" {
                if formData.mainType == "dynamicTextArea", tagInt == formData.formNumber {
                    formData.inputValue = textView.text!
                    self.oriFormData?.cells[tagInt].dynamicField?[textView.inputNumber].name = textView.text!
                }else {
                    if tagInt == formData.formNumber {
                        formData.inputValue = textView.text!
                        self.oriFormData?.cells[tagInt].textValue = textView.text!
                    }
                }
            }
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        let txtFieldPosition = textView.convert(textView.bounds.origin, to: tableView)
        let indexPath = tableView.indexPathForRow(at: txtFieldPosition)
        if let ip = indexPath {
            tableView.scrollToRow(at: ip, at: .bottom, animated: true)
        }
    }
    
    //因reload時，height重新計算會導致cell跳動，故紀錄tableview 的 content height
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightDictionary[indexPath.row] = cell.frame.size.height
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = heightDictionary[indexPath.row]
        return height ?? UITableView.automaticDimension
    }
    
    @IBAction func unwindToFormVC(segue: UIStoryboardSegue) {
        if segue.source is DFSelectionVC {
            if let selectionVC = segue.source as? DFSelectionVC {
                for formData in formDataList {
                    if formData.formType == "multipleSelection", formData.formId == selectionVC.id {
                        self.oriFormData?.cells[formData.formNumber!].dynamicField = []
                        formData.dynamicField = []
                        for option in selectionVC.chosenItemList {
                            formData.dynamicField?.append(option)
                            self.oriFormData?.cells[formData.formNumber!].dynamicField?.append(option)
                        }
                    }else if formData.formType == "singleSelection", formData.formId == selectionVC.id {
                        self.oriFormData?.cells[formData.formNumber!].dynamicField = []
                        formData.dynamicField = []
                        for option in selectionVC.chosenItemList {
                            formData.dynamicField?.append(option)
                            self.oriFormData?.cells[formData.formNumber!].dynamicField?.append(option)
                        }
                    }
                }
                tableView.reloadData()
            }
        }else if segue.source is DFElecSignVC {
            if let elecSignVC = segue.source as? DFElecSignVC {
                for formData in formDataList {
                    if formData.formType == "sign", formData.formNumber == elecSignVC.index {
                        
                        DispatchQueue.global(qos: .userInitiated).async {
                            DispatchQueue.main.async {
                                if let data = elecSignVC.signImage {
                                    if let image = UIImage(data: data){
                                        formData.image = image
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    //根據後綴獲取對應的Mime-Type
    private func mimeType(pathExtension: String) -> String {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                           pathExtension as NSString,
                                                           nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?
                .takeRetainedValue() {
                return mimetype as String
            }
        }
        //文件資源類型如果不知道，傳萬能類型application/octet-stream，服務器會自動解析文件類
        return "application/octet-stream"
    }
    
    private func dfShowActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
    }
    
    private func dfStopActivityIndicator() {
        if let indicator = activityIndicator {
            indicator.stopAnimating()
        }
    }
    
}

//擴展Data
extension Data {
    //增加直接添加String數據的方法
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
