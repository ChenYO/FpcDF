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

public class DFmainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, DynamicDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    //存放原始表單資料
    var oriFormDataList: [FormListData] = []
//    var oriFormData: FormListData?
    var keyboardPresented = false
    var screenHeight:CGFloat = 0.0
    
    var formDataList = [FormData]()
    
    var delegate: DynamicDelegate?
    var mainFormDelegate: DynamicDelegate?
    
    //存放各個dataFormatter
    var dateFormatterList = [dateFormatterObj]()
    
    var urlString: String?
    var tokenKey: String?
    var accessToken: String?
    var tokenURL: String?
    
    var activityIndicator: UIActivityIndicatorView!
    var isFirstLayer = true
    var isUsingJsonString = false
    var jsonStringList: [String] = []
    var formId = ""
    
    var isReadOnly = false
    var width: CGFloat = 0.0
    
    var searchTitle = ""
    var chooseDateSelf = false
    
    fileprivate var heightDictionary: [Int : CGFloat] = [:]
    
    public func dynamicSendForm(_ formId: String, _ formStringList: [String]) {
        
    }
    
    public func dynamicSaveForm(_ formId: String, _ formStringList: [String]) {
        
        var newFormList: [String] = []
        
        for formString in self.jsonStringList {
            do {
                let form = try DFUtil.decodeJsonStringAndReturnObject(string: formString, type: FormListData.self)
                
                if form.formID != formId {
                    newFormList.append(formString)
                }
            }catch {
                
            }
        }
        
        for formString in formStringList {
            newFormList.append(formString)
        }
        
        self.jsonStringList = newFormList
        
        print("save main form")
    }
    
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.width = self.view.frame.width - 20
            
            self.tableView.reloadData()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
//        if #available(iOS 15.0, *) {
//            tableView.sectionHeaderTopPadding = 0.0
//        }
        
        print("searchTitle: \(self.searchTitle)")
        width = self.view.frame.width - 20
        
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
        tableView.register(UINib(nibName: "DFTableCell", bundle: bundle), forCellReuseIdentifier: "DFTableCell")
        
        
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
        
        
        if isUsingJsonString {
            loadFromJsonString()
        }else {
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
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        dfStopActivityIndicator()
    }
    
    //依照是否有導覽列決定返回的動作
    @objc func back() {
        
        self.sendForm()
        
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
    
    //從 json string 取得表單
    func loadFromJsonString() {
        
//        let buttonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItem.Style.plain, target: self, action: #selector(finish))
        
        let saveItem = UIBarButtonItem(title: "儲存", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveFormFromButton))
        
        
//        if let tokenKey = tokenKey, tokenKey == "mobilefpcToken" {
//            buttonItem.tintColor = .white
//        }
        
//        self.navigationItem.rightBarButtonItems = [buttonItem, saveItem]
        
        if !isReadOnly {
            self.navigationItem.rightBarButtonItems = [saveItem]
        }
        
        
        if !self.jsonStringList.isEmpty {
            
            for jsonString in self.jsonStringList {
                do {
                    let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: FormListData.self)
                    
                    if obj.formID == self.formId {
                        self.title = obj.formTitle
                        self.oriFormDataList.append(obj)
                    }
                    
                } catch {
                }
            }
            
            self.setFormData()
            
            self.tableView.reloadData()
            
            self.scrollToSearchId()
        }
    }
 
    @objc func saveFormFromButton() {
        
        if !chooseDateSelf {
            for form in self.oriFormDataList {
                for cell in form.cells {
                    for subCell in cell.subCellDataList! {
                        if let isDefaultDate = subCell.isDefaultDate, isDefaultDate {
                            subCell.textValue = String(Date().timeIntervalSince1970 * 1000).components(separatedBy: ".").first
                            subCell.isDefaultDate = false
                        }
                    }
                }
            }
            
            for cell in formDataList {
                if let subCellDataList = cell.subCellDataList {
                    for subCell in subCellDataList {
                        if let isDefaultDate = subCell.isDefaultDate, isDefaultDate {
                            subCell.textValue = String(Date().timeIntervalSince1970 * 1000).components(separatedBy: ".").first
                            subCell.isDefaultDate = false
                        }
                    }
                }
            }
        }
        
        
        self.saveForm()
        
        self.sendForm()
        
        DFUtil.DFTipMessageAndConfirm(self, msg: "儲存完成", callback: {
            _ in
        })
    }
    
    func sendForm() {
        do {
            var formList: [String] = []
            
            for form in self.oriFormDataList {
                let jsonEncoder = JSONEncoder()
                let oriJsonData = try jsonEncoder.encode(form)
                let json = String(data: oriJsonData, encoding: String.Encoding.utf8)
                
                formList.append(json!)
            }
            

            if let callback = delegate {
                callback.dynamicSendForm(self.formId, formList)
            }
            
            
        } catch {
            
        }
    }
    
    @objc func saveForm() {
        do {
            var formList: [String] = []
            
            for form in self.oriFormDataList {
                let jsonEncoder = JSONEncoder()
                let oriJsonData = try jsonEncoder.encode(form)
                let json = String(data: oriJsonData, encoding: String.Encoding.utf8)
                
                formList.append(json!)
            }
            
            
//            UserDefaults.standard.set(formList, forKey: "formList")
            
            if let callback = delegate {
                callback.dynamicSaveForm(self.formId, formList)
            }
            
            if let callback = mainFormDelegate {
                callback.dynamicSaveForm(self.formId, formList)
            }
            
            
        } catch {
            
        }
    }
    
    @objc func finish() {
        var isFinish = true
        
        for form in self.oriFormDataList {
            
            if !isFinish {
                break
            }
            
            for cell in form.cells {
                
                if !isFinish {
                    break
                }
                
                if cell.type == "tableKey" {
                    for subCell in cell.subCellDataList! {
                        if !subCell.isFinish! {
                            isFinish = false
                            break
                        }
                    }
                }
                
            }
        }
        
        if !isFinish {
            let confirmSheet = UIAlertController(title: "訊息提示", message: "表單尚未完成", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "確定", style: .default, handler: {
                action in
                
            })
        
            confirmSheet.addAction(confirmAction)
            
            self.present(confirmSheet, animated: true, completion: nil)
        }else {
            let confirmSheet = UIAlertController(title: "訊息提示", message: "表單完成", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "確定", style: .default, handler: {
                action in
                
            })
        
            confirmSheet.addAction(confirmAction)
            
            self.present(confirmSheet, animated: true, completion: nil)
        }
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
                                        
                                        self.oriFormDataList.append(obj)
//                                        self.oriFormData = obj
                                        self.clear()
                                        
                                        self.title = obj.formTitle
                                        
                                        if !self.oriFormDataList.isEmpty {
                                            self.setButtons()
                                            self.setFormData()
                                        }
                                        
                                        self.dfStopActivityIndicator()
                                        self.tableView.reloadData()
                                    }
                                } catch {
                                }
                            }
                    }else if let data = json[DFJSONKey.data] as? [String] {
                        DispatchQueue.main.async {
                                do {
                                    
                                    print(data)
                                    
                                    if data.isEmpty {
                                        return
                                    }
                                    
                                    let jsonString = data[0]
                                    
//                                    let decoder = JSONDecoder()
//                                    decoder.dateDecodingStrategy = .millisecondsSince1970
//                                    let jsonData = try JSONSerialization.data(withJSONObject: form, options: .prettyPrinted)
//                                    let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                                    
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
                                        
                                        do {
                                            
                                            let decoder = JSONDecoder()
                                            decoder.dateDecodingStrategy = .millisecondsSince1970
                                            
                                            for jsonString in data {
                                                
//                                                let jsonData = try JSONSerialization.data(withJSONObject: form, options: .prettyPrinted)
//                                                let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                                                
                                                let obj = try DFUtil.decodeJsonStringAndReturnObject(string: jsonString, type: FormListData.self)
                                                
                                                self.title = obj.formTitle
                                                self.oriFormDataList.append(obj)
                                            }
                                            
    //                                        self.oriFormData = obj
                                            self.clear()
                                            
                                            if !self.oriFormDataList.isEmpty {
                                                self.setButtons()
                                                self.setFormData()
                                            }
                                            
                                            self.dfStopActivityIndicator()
                                            self.tableView.reloadData()
                                        } catch {
                                            
                                        }
                                        
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
            
            DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
                DispatchQueue.main.async {
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
                }
            }
//            self.present(alert, animated: true, completion: nil)
            
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
//        for (index, button) in oriFormData!.buttons.enumerated() {
        for (index, button) in self.oriFormDataList[0].buttons.enumerated() {
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
        
//        let button = oriFormData?.buttons[sender.tag]
        
        let button = self.oriFormDataList[0].buttons[sender.tag]
        
        //顯示多選項表單
        if button.type == "subForm" {
            let actionSheet = UIAlertController(title: button.actionTip, message: nil, preferredStyle: .actionSheet)
            
            for subButton in button.actions! {
                let action = UIAlertAction(title: subButton.title, style: .default, handler: {
                    action in
                    self.execAction(type: subButton.actionType!, title: (button.actionTip)!, urlString: subButton.url!)
                })
                
                actionSheet.addAction(action)
            }
            
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        }else {
            execAction(type: (button.type)!, title: (button.actionTip)!, urlString: (button.url)!)
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
                            let oriJsonData = try jsonEncoder.encode(self.oriFormDataList[0])
//                            let oriJsonData = try jsonEncoder.encode(self.oriFormData)
                            let json = String(data: oriJsonData, encoding: String.Encoding.utf8)
                            
                            let parameters = [
//                                "formId": self.oriFormData?.formId ?? "",
                                "formId": self.oriFormDataList[0].formID ?? "",
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
        
        for form in self.oriFormDataList {
            for i in 0..<form.cells.count {
                let cell = form.cells[i]
                cell.inputValue = nil
            }
        }
        
//        for i in 0..<(oriFormData?.cells.count)! {
//            let formData = oriFormData?.cells[i]
//            formData?.inputValue = nil
//        }
    }
    
    func setTableFormData() {
        formDataList = [FormData]()
        
        var index = 0
        for (formIndex, form) in oriFormDataList.enumerated() {
            for (cellIndex, formData) in form.cells.enumerated() {
                let data = FormData()
                
                data.formNumber = formIndex
                data.cellNumber = cellIndex
                data.index = index
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
                
                data.subCellDataList = formData.subCellDataList
                
                index += 1
                
                switch formData.type {
                case "tableKey":
                    
                    for (subIndex, subCell) in data.subCellDataList!.enumerated() {
                        
                        data.subCellDataList![subIndex].isFinish = true
                        
                        if subCell.cellHeight != 0 {
                            data.subCellDataList![subIndex].height = CGFloat(subCell.cellHeight!)
                        }
                        
                        if subCell.subType == "dropDown" {
                            if subCell.textValue != "" {
                                for option in subCell.options! {
                                    if option.id == subCell.textValue {
                                        subCell.title = option.name
                                    }
                                }
                            }
                        }
                        
                        if subCell.subType == "dropDown" || subCell.subType == "textArea" || subCell.subType == "date" || subCell.subType == "time" || subCell.subType == "dateTime" || subCell.subType == "radio" || subCell.subType == "singleChoice" || subCell.subType == "textChoice" || subCell.subType == "textMultiChoice" || subCell.subType == "combineOption" || subCell.subType == "functionDropDown" || subCell.subType == "limitTextArea"{
                            
                            if subCell.textValue == "" {
                                data.subCellDataList![subIndex].isFinish = false
                            }
                            
                        }else if subCell.subType == "checkBox" {
                            
                            if subCell.choiceValue!.isEmpty {
                                data.subCellDataList![subIndex].isFinish = false
                            }
                        }else if subCell.subType == "sign" {
                            
//                            if subCell.textValue == "" {
//                                data.subCellDataList![subIndex].isFinish = false
//                            }
                            
                            if subCell.fileUrl == "" {
                                data.subCellDataList![subIndex].isFinish = false
                            }
                        }
                    }
                    
                    formDataList.append(data)
                case "tableTextField":
                    formDataList.append(data)
                default:
                    formDataList.append(data)
                }
            }
        }
    }
    
    //設定表單UI資料，須記錄每個cell的index
    func setFormData() {
        formDataList = [FormData]()
        
        var index = 0
        for (formIndex, form) in oriFormDataList.enumerated() {
            for (cellIndex, formData) in form.cells.enumerated() {
                let data = FormData()
                
                data.formNumber = formIndex
                data.cellNumber = cellIndex
                data.index = index
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
                
                data.subCellDataList = formData.subCellDataList
                
                index += 1
                
                switch formData.type {
                case "radio", "checkbox":
                    data.title = formData.title
                    data.formType = "label"
                    formDataList.append(data)
                    
                    for (optionIndex, radioOption) in formData.options!.enumerated() {
                        let option = FormData()
                        option.formNumber = formIndex
                        option.cellNumber = cellIndex
                        option.index = index
                        
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
                        attachmentData.index = index
                        attachmentData.formNumber = formIndex
                        attachmentData.cellNumber = cellIndex
                        attachmentData.title = attachment.title
                        attachmentData.formType = attachment.type
                        attachmentData.isReadOnly = formData.isReadOnly
                        attachmentData.fileUrl = attachment.url
                        formDataList.append(attachmentData)
                    }
                case "picture":
                    for picture in formData.fileList! {
                        let pictureData = FormData()
                        pictureData.index = index
                        pictureData.formNumber = formIndex
                        pictureData.cellNumber = cellIndex
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
//                    setDynamicInputData(formData: formData, index: index, formType: "textField")
                    
                    for i in 0..<formData.count! {
                        let inputField = FormData()
                        inputField.index = index
                        inputField.formNumber = formIndex
                        inputField.cellNumber = cellIndex
                        inputField.inputNumber = i
                        inputField.formType = "textField"
                        inputField.mainType = formData.type
                        inputField.isReadOnly = formData.isReadOnly
                        
                        index += 1
                        
                        formDataList.append(inputField)
                    }
                case "dynamicTextArea":
                    formDataList.append(data)
//                    setDynamicInputData(formData: formData, index: index, formType: "textArea")
                    
                    for i in 0..<formData.count! {
                        let inputField = FormData()
                        inputField.index = index
                        inputField.formNumber = formIndex
                        inputField.cellNumber = cellIndex
                        inputField.inputNumber = i
                        inputField.formType = "textArea"
                        inputField.mainType = formData.type
                        inputField.isReadOnly = formData.isReadOnly
                        
                        index += 1
                        
                        formDataList.append(inputField)
                    }
                    
                case "singleSelection", "multipleSelection":
                    formDataList.append(data)
                    
                case "upload":
                    formDataList.append(data)
                    setFileData(formData: formData, formNumber: formIndex, cellNumber: cellIndex)
                    
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
                case "tableKey":
                    
                    for (subIndex, subCell) in data.subCellDataList!.enumerated() {
                        
                        data.subCellDataList![subIndex].isFinish = true
                        
                        if subCell.cellHeight != 0 {
                            data.subCellDataList![subIndex].height = CGFloat(subCell.cellHeight!)
                        }
                        
                        if subCell.subType == "dropDown" {
                            if subCell.textValue != "" {
                                for option in subCell.options! {
                                    if option.id == subCell.textValue {
                                        subCell.title = option.name
                                    }
                                }
                            }
                        }
                        
                        if subCell.isRequired! && !subCell.isOptional! {
                            if subCell.subType == "dropDown" || subCell.subType == "textArea" || subCell.subType == "date" || subCell.subType == "time" || subCell.subType == "dateTime" || subCell.subType == "radio" || subCell.subType == "singleChoice" || subCell.subType == "textChoice" || subCell.subType == "textMultiChoice" || subCell.subType == "combineOption" || subCell.subType == "functionDropDown" || subCell.subType == "limitTextArea"{
                           
                                if subCell.textValue == "" {
                                    data.subCellDataList![subIndex].isFinish = false
                                }
                                
                                if let isDefaultDate = subCell.isDefaultDate, isDefaultDate {
                                    if subCell.subType == "date" || subCell.subType == "time" || subCell.subType == "dateTime" {
                                        data.subCellDataList![subIndex].textValue = String(Date().timeIntervalSince1970 * 1000).components(separatedBy: ".").first
                                    }
                                }
                                
                                
                            }else if subCell.subType == "checkBox" {
                                
                                if subCell.choiceValue!.isEmpty {
                                    data.subCellDataList![subIndex].isFinish = false
                                }
                            }else if subCell.subType == "sign" {
                                
//                                if subCell.textValue == "" {
//                                    data.subCellDataList![subIndex].isFinish = false
//                                }
                                
                                if subCell.fileUrl == "" {
                                    data.subCellDataList![subIndex].isFinish = false
                                }
                            }
                        }
                    }
                    
                    formDataList.append(data)
                default:
                    formDataList.append(data)
                }
            }
            
            let data = FormData()
            
            data.formNumber = formIndex
            data.index = index
     
            index += 1
            
            formDataList.append(data)
        }
        
    }
    
    //尋找特定ID並移到該位置
    func scrollToSearchId() {
        
        if self.searchTitle != "" {
            var searchIdIndex = 0
            
            for (index, cell) in formDataList.enumerated() {
                
                if let subCellDataList = cell.subCellDataList {
                    for subCell in subCellDataList {
                        if subCell.title == self.searchTitle {
                            searchIdIndex = index
                            break
                        }
                    }
                }
            }
            
            if searchIdIndex - 2 >= 0 {
                searchIdIndex = searchIdIndex - 2
            }
            
            if !formDataList.isEmpty {
                self.tableView.scrollToRow(at: IndexPath(row: searchIdIndex, section: 0), at: .top, animated: true)
            }
            
            
        }
    }
    
    //設定動態列表資料
    func setDynamicInputData(formData: cell, formNumber: Int, cellNumber: Int, formType: String) {
        for i in 0..<formData.count! {
            let inputField = FormData()
            inputField.formNumber = formNumber
            inputField.cellNumber = cellNumber
            inputField.inputNumber = i
            inputField.formType = formType
            inputField.mainType = formData.type
            inputField.isReadOnly = formData.isReadOnly
            
            formDataList.append(inputField)
        }
    }
    
    //設定附件/照片資料
    func setFileData(formData: cell, formNumber: Int, cellNumber: Int) {
        if let fileList = formData.fileList {
            for i in 0..<fileList.count {
                let file = fileList[i]
                if file.type == "picture" {
                    insertPicture(formNumber: formNumber, cellNumber: cellNumber, title: file.title!, mainType: formData.type!, inputNumber: i, isReadOnly: formData.isReadOnly!, imageUrlString: file.url!)
                }else if file.type == "attachment" {
                    let attachmentData = FormData()
                    attachmentData.formNumber = formNumber
                    attachmentData.cellNumber = cellNumber
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
    func insertPicture(formNumber: Int, cellNumber: Int, title: String, mainType: String, inputNumber: Int, isReadOnly: Bool, imageUrlString: String) {
        let pictureData = FormData()
        pictureData.formNumber = formNumber
        pictureData.cellNumber = cellNumber
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
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let inputIndex = sender.index
        
        self.oriFormDataList[formNumber].cells[cellNumber].dynamicField?.remove(at: inputIndex)
        self.oriFormDataList[formNumber].cells[cellNumber].count = self.oriFormDataList[formNumber].cells[cellNumber].count! - 1
        
        var newIndex = 0
        
        for (index, formData) in formDataList.enumerated() {
            if formData.formType == "textField" {
                if formData.mainType == "dynamicTextField", formNumber == formData.formNumber, cellNumber == formData.cellNumber, inputIndex == formData.inputNumber {
                    formDataList.remove(at: index)
                    break
                }
            }else if formData.formType == "textArea" {
                if formData.mainType == "dynamicTextArea", formNumber == formData.formNumber, cellNumber == formData.cellNumber, inputIndex == formData.inputNumber {
                    formDataList.remove(at: index)
                    break
                }
            }
        }
        
        for formData in formDataList {
            if formData.formType == "textField" {
                if formData.mainType == "dynamicTextField", formNumber == formData.formNumber, cellNumber == formData.cellNumber {
                    
                    if newIndex > self.oriFormDataList[formNumber].cells[cellNumber].count! {
                        break
                    }
                    formData.inputNumber = newIndex
                    newIndex += 1
                }
            }else if formData.formType == "textArea" {
                if formData.mainType == "dynamicTextArea", formNumber == formData.formNumber, cellNumber == formData.cellNumber {
                    
                    if newIndex > self.oriFormDataList[formNumber].cells[cellNumber].count! {
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
        let formNumber = sender.formNumber
        let cellNumber = sender.cellNumber
        let inputNumber = sender.inputNumber
        
        self.oriFormDataList[formNumber].cells[cellNumber].fileList?.remove(at: inputNumber)
        
        var newIndex = 0
        
        for (index, formData) in formDataList.enumerated() {
            if formData.formType == "picture" {
                if formData.mainType == "upload", formNumber == formData.formNumber, cellNumber == formData.cellNumber, inputNumber == formData.inputNumber {
                    formDataList.remove(at: index)
                    break
                }
            }else if formData.formType == "attachment" {
                if formData.mainType == "upload", formNumber == formData.formNumber, cellNumber == formData.cellNumber, inputNumber == formData.inputNumber {
                    formDataList.remove(at: index)
                    break
                }
            }
        }
        
        
        for formData in formDataList {
            if formData.formType == "picture" {
                if formData.mainType == "upload", formNumber == formData.formNumber, cellNumber == formData.cellNumber {
                    if newIndex > self.oriFormDataList[formNumber].cells[cellNumber].fileList!.count {
                        break
                    }
                    formData.inputNumber = newIndex
                    newIndex += 1
                }
            }else if formData.formType == "attachment" {
                if formData.mainType == "upload", formNumber == formData.formNumber, cellNumber == formData.cellNumber {
                    if newIndex > self.oriFormDataList[formNumber].cells[cellNumber].fileList!.count {
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
        if let fontSize = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].titleFont?.size {
            cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
//            cell.constraint?.constant = CGFloat(fontSize)
        }
        
        if let fontColor = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].titleFont?.color {
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
        let cellNumber = formData.cellNumber ?? 0
        
        cell.title.text = ""
        
        switch formData.formType {
        case "label":
            
            if let fontSize = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.size {
                cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let fontColor = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.color {
                cell.title.textColor = UIColor(hexString: fontColor)
            }
            
            if let required = self.oriFormDataList[formNumber!].cells[cellNumber].isRequired {
                cell.requireLabel.isHidden = !required
            }
            
            cell.title.text = formData.title
            return cell
        case "textField":
            //輸入列與動態輸入列的產生
            
            let cell: FormTextFieldCell = tableView.dequeueReusableCell(withIdentifier: "FormTextFieldCell", for: indexPath) as! FormTextFieldCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.title.text = ""
            cell.inputField.placeholder = ""
            cell.inputField.keyboardType = UIKeyboardType.default
            
            setFont(cell: cell, formNumber: formNumber!, formData: formData)
            
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
            }
            
            if let isReadOnly = formData.isReadOnly {
                if isReadOnly {
                    cell.isUserInteractionEnabled = false
                }else {
                    cell.isUserInteractionEnabled = true
                }
            }
            
            if let inputConfig = self.oriFormDataList[formNumber!].cells[cellNumber].inputConfig {
                if let placeholder = inputConfig.placeholder {
                    cell.inputField.placeholder = placeholder
                }
                
                if let type = inputConfig.type {
                    if type == "number" {
                        cell.inputField.keyboardType = UIKeyboardType.decimalPad
                    }
                }
            }
            
            if self.oriFormDataList[formNumber!].cells[cellNumber].textValue == nil {
                cell.inputField.text = ""
            }
            cell.inputField.delegate = self
            cell.inputField.tag = formNumber!
            cell.inputField.inputNumber = cellNumber
            cell.inputField.cellIndex = cellNumber
            
            //若為動態輸入列，則可以刪除
            if formData.mainType == "dynamicTextField" {
                let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteTapped))
                
                deleteRecognizer.formNumber = formData.formNumber!
                deleteRecognizer.index = formData.inputNumber!
                deleteRecognizer.inputNumber = formData.cellNumber!
                cell.deleteIcon.addGestureRecognizer(deleteRecognizer)
                cell.deleteIcon.isHidden = false
                cell.imageConstraint?.constant = 25
                cell.deleteIcon.tag = formData.index!
                cell.deleteIcon.formNumber = formNumber!
                cell.deleteIcon.cellNumber = cellNumber
                
                cell.inputField.inputNumber = formData.inputNumber!
                cell.inputField.cellIndex = formData.cellNumber!
                cell.inputField.formNumber = formData.formNumber!
                
                for (index, input) in self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].dynamicField!.enumerated() {
                    
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
            
            cell.title.text = ""
            
            if let fontSize = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.size {
                cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let fontColor = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.color {
                cell.title.textColor = UIColor(hexString: fontColor)
            }
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
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
            
            if self.oriFormDataList[formNumber!].cells[cellNumber].textValue == nil {
                cell.formTextArea.text = ""
            }
            cell.formTextArea.delegate = self
            cell.formTextArea.layer.borderWidth = 1.0
            cell.formTextArea.layer.borderColor = UIColor.lightGray.cgColor
            cell.formTextArea.layer.cornerRadius = 5.0
            cell.formTextArea.tag = formNumber!
            cell.formTextArea.inputNumber = cellNumber
            cell.formTextArea.signleCellIndex = cellNumber
            
            //若為動態輸入列，則可以刪除
            if formData.mainType == "dynamicTextArea" {
                let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteTapped))
                
                deleteRecognizer.formNumber = formData.formNumber!
                deleteRecognizer.index = formData.inputNumber!
                deleteRecognizer.inputNumber = formData.cellNumber!
                cell.deleteIcon.addGestureRecognizer(deleteRecognizer)
                cell.deleteIcon.isHidden = false
                cell.imageConstraint?.constant = 25
                cell.deleteIcon.tag = formData.index!
                cell.deleteIcon.formNumber = formNumber!
                cell.deleteIcon.cellNumber = cellNumber
                
                cell.formTextArea.signleInputIndex = formData.inputNumber!
                cell.formTextArea.signleCellIndex = formData.cellNumber!
                cell.formTextArea.formNumber = formData.formNumber!
                
                for (index, input) in self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].dynamicField!.enumerated() {
                    
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
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
            }
            
            setDateCell(formData: formData, type: "date", format: "yyyy-MM-dd", formNumber: formNumber!, cell: cell)
            
            return cell
        case "time":
            let cell: FormTextFieldCell = tableView.dequeueReusableCell(withIdentifier: "FormTextFieldCell", for: indexPath) as! FormTextFieldCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
            }
            
            setDateCell(formData: formData, type: "time", format: "HH:mm", formNumber: formNumber!, cell: cell)
            
            return cell
        case "dateTime":
            let cell: FormTextFieldCell = tableView.dequeueReusableCell(withIdentifier: "FormTextFieldCell", for: indexPath) as! FormTextFieldCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
            }
            
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
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
            }
            
            if formData.mainType == "upload" {
                if formData.isReadOnly! {
                    cell.deleteIcon.isHidden = true
                }else {
                    cell.deleteIcon.isHidden = false
                }
                
                let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteFileTapped))
                
                deleteRecognizer.formNumber = formNumber!
                deleteRecognizer.cellNumber = cellNumber
                deleteRecognizer.inputNumber = formData.inputNumber!
                cell.deleteIcon.addGestureRecognizer(deleteRecognizer)
                
                cell.deleteIcon.formNumber = formNumber!
                cell.deleteIcon.cellNumber = cellNumber
                cell.deleteIcon.inputNumber = formData.inputNumber!
                
                
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
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
            }
            
            if formData.mainType == "upload" {
                if formData.isReadOnly! {
                    cell.deleteIcon.isHidden = true
                }else {
                    cell.deleteIcon.isHidden = false
                }
                
                let deleteRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteFileTapped))
                
                deleteRecognizer.formNumber = formNumber!
                deleteRecognizer.cellNumber = cellNumber
                deleteRecognizer.inputNumber = formData.inputNumber!
                cell.deleteIcon.addGestureRecognizer(deleteRecognizer)
                
                cell.deleteIcon.formNumber = formNumber!
                cell.deleteIcon.cellNumber = cellNumber
                cell.deleteIcon.inputNumber = formData.inputNumber!
            }
            
            return cell
        case "dynamicTextField", "dynamicTextArea":
            let cell: DynamicFieldCell = tableView.dequeueReusableCell(withIdentifier: "DynamicFieldCell", for: indexPath) as! DynamicFieldCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
            }
            
            if let fontSize = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.size {
                cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let fontColor = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.color {
                cell.title.textColor = UIColor(hexString: fontColor)
            }
            
            cell.title.text = formData.title
            
            return cell
        case "singleSelection", "multipleSelection":
            let cell: SingleSelectionCell = tableView.dequeueReusableCell(withIdentifier: "SingleSelectionCell", for: indexPath) as! SingleSelectionCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.actionTip.text = formData.title
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
            }
            
            if let fontSize = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.size {
                cell.actionTip.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let fontColor = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.color {
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
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
                if let signUrl = self.oriFormDataList[formNumber!].cells[cellNumber].fileUrl {
                    let fileUrl = URL(string: "https://appcloud.fpcetg.com.tw/eformapi/uploads/\(signUrl)")
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData = NSData(contentsOf: fileUrl!) {
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData as Data) {
                                    cell.signImageView.image = image
                                }
                            }
                        }
                    }
                    
                    
//                    if let imageData = NSData(contentsOf: fileUrl!) {
//                        if let image = UIImage(data: imageData as Data) {
//                            cell.signImageView.image = image
//                        }
//                    }
                }
            }else {
                cell.isUserInteractionEnabled = true
                
                if let signUrl = self.oriFormDataList[formNumber!].cells[cellNumber].fileUrl {
                    let fileURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!).appendingPathComponent(signUrl)
                    if let imageData = NSData(contentsOf: fileURL!) {
                        let image = UIImage(data: imageData as Data)
                        
                        cell.signImageView.image = image
                    }
                }
                
            }
            
            if let fontSize = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.size {
                cell.title.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
            
            if let fontColor = self.oriFormDataList[formNumber!].cells[cellNumber].titleFont?.color {
                cell.title.textColor = UIColor(hexString: fontColor)
            }
            
            cell.title.text = formData.title
            cell.signImageView.image = nil
            
            

            return cell
        case "tableKey":
            let cell: DFTableCell = tableView.dequeueReusableCell(withIdentifier: "DFTableCell", for: indexPath) as! DFTableCell
            cell.selectionStyle = .none
            
            if isReadOnly {
                cell.isUserInteractionEnabled = false
            }else {
                cell.isUserInteractionEnabled = true
            }
            
            setTableCell(cell: cell, formData: formData)
            
            return cell

        default:
            return cell
        }
    }
    
    @objc func toolBarCancelClick(sender: UIBarButtonItem) {
        print(sender.tag)
        let formNumber = sender.tag
        let cellNumber = sender.inputNumber
        
        for dateFormatter in dateFormatterList {
            if dateFormatter.index == formNumber, dateFormatter.cellIndex == cellNumber {
                let timeInterval:TimeInterval = (dateFormatter.datePicker?.date.timeIntervalSince1970)!
                print(timeInterval)
                
                self.oriFormDataList[formNumber].cells[cellNumber].textValue = ""
            }
        }
        
        for formData in formDataList {
            if sender.tag == formData.formNumber, sender.inputNumber == formData.cellNumber {
                
                formData.inputValue = self.oriFormDataList[formNumber].cells[cellNumber].textValue
                
            }
        }
        
        self.tableView.reloadData()
        self.view.endEditing(true)
    }
    
    @objc func doneButtonTapped(sender: UIBarButtonItem) {
        // 依據元件的 tag 取得 UITextField
        print(sender.tag)
        
        let formNumber = sender.tag
        let cellNumber = sender.inputNumber
        
        for dateFormatter in dateFormatterList {
            if dateFormatter.index == formNumber, dateFormatter.cellIndex == cellNumber {
                let timeInterval:TimeInterval = (dateFormatter.datePicker?.date.timeIntervalSince1970)!
                print(timeInterval)
                self.oriFormDataList[formNumber].cells[cellNumber].textValue = String(dateFormatter.datePicker!.date.timeIntervalSince1970 * 1000).components(separatedBy: ".").first
            }
        }
        
        for formData in formDataList {
            if sender.tag == formData.formNumber, sender.inputNumber == formData.cellNumber {
                formData.inputValue = self.oriFormDataList[formNumber].cells[cellNumber].textValue
            }
        }
        
        self.saveForm()
        
        self.tableView.reloadData()
        self.view.endEditing(true)
    }
    
    func setDateCell(formData: FormData, type: String, format: String, formNumber: Int, cell: FormTextFieldCell) {
        
        let cellNumber = formData.cellNumber!
        
        if formData.isReadOnly! {
            cell.inputField.isUserInteractionEnabled = false
        }else {
            cell.inputField.isUserInteractionEnabled = true
        }
        
        if let inputConfig = self.oriFormDataList[formNumber].cells[cellNumber].inputConfig {
            if let placeholder = inputConfig.placeholder {
                cell.inputField.placeholder = placeholder
            }
        }
        
        setFont(cell: cell, formNumber: formNumber, formData: formData)
        setDatePicker(type: type, formNumber: formNumber, cellNumber: cellNumber, cell: cell)
        
        
        cell.inputField.text = ""
        cell.inputField.tag = formNumber
        cell.inputField.inputNumber = cellNumber
        
        if formData.inputValue != "" {
            cell.inputField.text = setTimestampToDate(timestampString: formData.inputValue!, format: format)
        }
        
        cell.deleteIcon.isHidden = true
    }
    
    //設定date, time, dateTime
    func setDatePicker(type: String, formNumber: Int, cellNumber: Int, cell: FormTextFieldCell) {
        let toolBar = UIToolbar()
        let formatter = DateFormatter()
        let datePicker:UIDatePicker = UIDatePicker()
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
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
        dateFormatter.cellIndex = cellNumber
        dateFormatter.dateFormatter = formatter
        dateFormatter.datePicker = datePicker
        dateFormatterList.append(dateFormatter)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let cancelButton = UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(toolBarCancelClick))
        toolBar.setItems([doneButton, cancelButton], animated: true)
        
        doneButton.tag = formNumber
        doneButton.inputNumber = cellNumber
        
        cancelButton.tag = formNumber
        cancelButton.inputNumber = cellNumber
        
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
    
    
    func setTableCell(cell: DFTableCell, formData: FormData) {
        let cellNumber = formData.cellNumber!
        
        if formData.subCellDataList!.count >= 1 {
            setTableDetailCell(key: cell.key1, imageView: cell.imageView1, keyWidth: cell.keyWidth1, keyHeight: cell.keyHeight1, keyGap: cell.keyGap1, keyTop: cell.keyTop1, imageHeight: cell.imageHeight1, ImageGap: cell.keyGap1, cellNumber: cellNumber, subCellIndex: 0, formData: formData, cell: cell)
        }
        
        if formData.subCellDataList!.count >= 2 {
            setTableDetailCell(key: cell.key2, imageView: cell.imageView2, keyWidth: cell.keyWidth2, keyHeight: cell.keyHeight2, keyGap: cell.keyGap1, keyTop: cell.keyTop2, imageHeight: cell.imageHeight2, ImageGap: cell.ImageGap1, cellNumber: cellNumber, subCellIndex: 1, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 3 {
            setTableDetailCell(key: cell.key3, imageView: cell.imageView3, keyWidth: cell.keyWidth3, keyHeight: cell.keyHeight3, keyGap: cell.keyGap2, keyTop: cell.keyTop3, imageHeight: cell.imageHeight3, ImageGap: cell.ImageGap2, cellNumber: cellNumber, subCellIndex: 2, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 4 {
            setTableDetailCell(key: cell.key4, imageView: cell.imageView4, keyWidth: cell.keyWidth4, keyHeight: cell.keyHeight4, keyGap: cell.keyGap3, keyTop: cell.keyTop4, imageHeight: cell.imageHeight4, ImageGap: cell.ImageGap3, cellNumber: cellNumber, subCellIndex: 3, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 5 {
            setTableDetailCell(key: cell.key5, imageView: cell.imageView5, keyWidth: cell.keyWidth5, keyHeight: cell.keyHeight5, keyGap: cell.keyGap4, keyTop: cell.keyTop5, imageHeight: cell.imageHeight5, ImageGap: cell.ImageGap4, cellNumber: cellNumber, subCellIndex: 4, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 6 {
            setTableDetailCell(key: cell.key6, imageView: cell.imageView6, keyWidth: cell.keyWidth6, keyHeight: cell.keyHeight6, keyGap: cell.keyGap5, keyTop: cell.keyTop6, imageHeight: cell.imageHeight6, ImageGap: cell.ImageGap5, cellNumber: cellNumber, subCellIndex: 5, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 7 {
            setTableDetailCell(key: cell.key7, imageView: cell.imageView7, keyWidth: cell.keyWidth7, keyHeight: cell.keyHeight7, keyGap: cell.keyGap6, keyTop: cell.keyTop7, imageHeight: cell.imageHeight7, ImageGap: cell.ImageGap6, cellNumber: cellNumber, subCellIndex: 6, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 8 {
            setTableDetailCell(key: cell.key8, imageView: cell.imageView8, keyWidth: cell.keyWidth8, keyHeight: cell.keyHeight8, keyGap: cell.keyGap7, keyTop: cell.keyTop8, imageHeight: cell.imageHeight8, ImageGap: cell.ImageGap7, cellNumber: cellNumber, subCellIndex: 7, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 9 {
            setTableDetailCell(key: cell.key9, imageView: cell.imageView9, keyWidth: cell.keyWidth9, keyHeight: cell.keyHeight9, keyGap: cell.keyGap8, keyTop: cell.keyTop9, imageHeight: cell.imageHeight9, ImageGap: cell.ImageGap8, cellNumber: cellNumber, subCellIndex: 8, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 10 {
            setTableDetailCell(key: cell.key10, imageView: cell.imageView10, keyWidth: cell.keyWidth10, keyHeight: cell.keyHeight10, keyGap: cell.keyGap9, keyTop: cell.keyTop10, imageHeight: cell.imageHeight10, ImageGap: cell.ImageGap9, cellNumber: cellNumber, subCellIndex: 9, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 11 {
            setTableDetailCell(key: cell.key11, imageView: cell.imageView11, keyWidth: cell.keyWidth11, keyHeight: cell.keyHeight11, keyGap: cell.keyGap10, keyTop: cell.keyTop11, imageHeight: cell.imageHeight11, ImageGap: cell.ImageGap10, cellNumber: cellNumber, subCellIndex: 10, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 12 {
            setTableDetailCell(key: cell.key12, imageView: cell.imageView12, keyWidth: cell.keyWidth12, keyHeight: cell.keyHeight12, keyGap: cell.keyGap11, keyTop: cell.keyTop12, imageHeight: cell.imageHeight12, ImageGap: cell.ImageGap11, cellNumber: cellNumber, subCellIndex: 11, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 13 {
            setTableDetailCell(key: cell.key13, imageView: cell.imageView13, keyWidth: cell.keyWidth13, keyHeight: cell.keyHeight13, keyGap: cell.keyGap12, keyTop: cell.keyTop13, imageHeight: cell.imageHeight13, ImageGap: cell.ImageGap12, cellNumber: cellNumber, subCellIndex: 12, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 14 {
            setTableDetailCell(key: cell.key14, imageView: cell.imageView14, keyWidth: cell.keyWidth14, keyHeight: cell.keyHeight14, keyGap: cell.keyGap13, keyTop: cell.keyTop14, imageHeight: cell.imageHeight14, ImageGap: cell.ImageGap13, cellNumber: cellNumber, subCellIndex: 13, formData: formData, cell: cell)
        }

        if formData.subCellDataList!.count >= 15 {
            setTableDetailCell(key: cell.key15, imageView: cell.imageView15, keyWidth: cell.keyWidth15, keyHeight: cell.keyHeight15, keyGap: cell.keyGap14, keyTop: cell.keyTop15, imageHeight: cell.imageHeight15, ImageGap: cell.ImageGap14, cellNumber: cellNumber, subCellIndex: 14, formData: formData, cell: cell)
        }
    }
    
    func setTableDetailCell(key: UITextView, imageView: UIImageView, keyWidth: NSLayoutConstraint, keyHeight: NSLayoutConstraint, keyGap: NSLayoutConstraint, keyTop: NSLayoutConstraint, imageHeight: NSLayoutConstraint, ImageGap: NSLayoutConstraint, cellNumber: Int, subCellIndex: Int, formData: FormData, cell: DFTableCell) {
        let subCell = formData.subCellDataList![subCellIndex]
        
        let formNumber = formData.formNumber
        
        if let fontSize = oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].titleFont?.size {
            if let isBold = oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].isBold, isBold {
                key.font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
            }else {
                key.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            }
        }
        
        if let fontColor = oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].titleFont?.color {
            key.textColor = UIColor(hexString: fontColor)
        }
        
        if let alignment = oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].titleFont?.alignment {
            
            if alignment == "left" {
                key.textAlignment = .left
            }else if alignment == "right" {
                key.textAlignment = .right
            }else {
                key.textAlignment = .center
            }
        }

        
        key.layer.borderWidth = 1
        key.layer.borderColor = UIColor.black.cgColor
        
        if oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].isFinish! {
            key.backgroundColor = .white
            
            if subCell.isRequired! {
                key.textColor = UIColor(hexString: subCell.finishColor!)
                
                if subCell.isOptional! {
//                    key.backgroundColor = UIColor(hexString: "#F0F0F0")
                }
            }
            
        }else {
            key.backgroundColor = UIColor(hexString: "#D0D0D0")
        }
        
        
        
        key.isHidden = false
        key.delegate = self
        key.isUserInteractionEnabled = true
        
        key.width = keyWidth.constant
        key.index = formData.index!
        key.tag = subCellIndex
        key.formNumber = formNumber!
        key.inputNumber = cellNumber
        imageView.tag = subCellIndex
        imageView.formNumber = formNumber!
        imageView.inputNumber = cellNumber
        
        keyWidth.constant = width * CGFloat(subCell.width!) / 100
        
        
        imageView.isHidden = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
        
        
        
        if let height = subCell.height {
            keyHeight.constant = height
        }
        
        imageHeight.constant = keyHeight.constant
        
        if let gap = subCell.cellGap {
            if subCellIndex != 0 {
                keyGap.constant = width * CGFloat(gap) / 100
                ImageGap.constant = width * CGFloat(gap) / 100
            }
        }
        
        if let borderColor = subCell.borderColor {
            key.layer.borderColor = UIColor(hexString: borderColor).cgColor
        }
        
        key.text = subCell.title
        
        key.isScrollEnabled = false
        key.isEditable = true
        
        if subCell.keyBoardType == "number" {
            key.keyboardType = UIKeyboardType.decimalPad
        }else {
            key.keyboardType = .default
        }
        
        if subCell.subType == "label" {
            
//            key.backgroundColor = UIColor(hexString: "#F0F0F0")
            key.isEditable = false
            
        }else if subCell.subType == "textArea" {
            
            key.isScrollEnabled = true
            
            if subCell.textValue != "" {
                key.text = subCell.textValue
            }
            
        }else if subCell.subType == "dropDown" {
            
            key.isEditable = false
            
            let recognizer = getDropDownGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            key.addGestureRecognizer(recognizer)
            
            if subCell.textValue != "" {
                for option in subCell.options! {
                    if option.id == subCell.textValue {
                        key.text = option.name
                        if subCell.isRequired! {
                            key.textColor = UIColor(hexString: option.color!)
                            
                        }
                    }
                }
            }
            
            
        }else if subCell.subType == "date" || subCell.subType == "time" || subCell.subType == "dateTime" {
            
            key.isEditable = false
            var format = "yyyy-MM-dd"
            
            if subCell.subType == "time" {
                format = "HH:mm"
            }
            
            if subCell.subType == "dateTime" {
                format = "yyyy-MM-dd HH:mm"
            }
            
            setTableTextFieldDatePicker(type: subCell.subType!, index: formData.index!, formNumber: formNumber!, cellNumber: formData.cellNumber!, subCellIndex: subCellIndex, key: key)
            
            if formData.subCellDataList![subCellIndex].textValue != "" {
                key.text = setTimestampToDate(timestampString: formData.subCellDataList![subCellIndex].textValue!, format: format)
            }
            
        }else if subCell.subType == "radio" {
            
            let recognizer = getRadioGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            key.addGestureRecognizer(recognizer)
            
            var optionStr = ""
            var startIndex = 0
            var range: NSRange?
            var selectedColor = ""
            
            for (index, option) in subCell.options!.enumerated() {
                
                var optionNameString = ""
                
                if option.id == subCell.textValue! {
                    selectedColor = option.color!
                    optionNameString = "◉ \(option.name ?? "")  "
                    range = NSRange(location: startIndex, length: optionNameString.count - 2)
                }else {
                    optionNameString = "○ \(option.name ?? "")  "
                }
                
                startIndex += optionNameString.count
                optionStr += optionNameString
                
                if !subCell.isHorizon! {
                    if index != subCell.options!.count - 1 {
                        optionStr += "\n"
                        startIndex += 1
                    }
                }
                
            }
            let fontSize = oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].titleFont?.size ?? 16
            
            let style = NSMutableParagraphStyle()
            
            if let alignment = oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].titleFont?.alignment {
                
                if alignment == "left" {
                    style.alignment = NSTextAlignment.left
                }else if alignment == "right" {
                    style.alignment = NSTextAlignment.right
                }else {
                    style.alignment = NSTextAlignment.center
                }
            }
            
            
            let attributedString = NSMutableAttributedString(string: optionStr, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
                 NSAttributedString.Key.paragraphStyle: style])
            
            if subCell.isRequired! {
                
                if let realRange = range {
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: selectedColor) , range: realRange)
                    key.attributedText = attributedString
                }else {
                    key.text = optionStr
                }
                
            }else {
                key.text = optionStr
            }
            
        }else if subCell.subType == "checkBox" {
            
            let recognizer = getCheckBoxGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            key.addGestureRecognizer(recognizer)
            
            var optionStr = ""
            var startIndex = 0
            var rangeList: [NSRange] = []
            var selectedColorList: [String] = []
            
            for (index, option) in subCell.options!.enumerated() {
                
                var optionNameString = ""
                if subCell.choiceValue!.contains(option.id!) {
                    optionNameString = "▣ \(option.name ?? "")  "
                    
                    selectedColorList.append(option.color!)
                    
                    let range = NSRange(location: startIndex, length: optionNameString.count - 2 )
                    rangeList.append(range)
   
                }else {
                    optionNameString = "□ \(option.name ?? "")  "
                }

                startIndex += optionNameString.count
                optionStr += optionNameString
                
                if !subCell.isHorizon! {
                    if index != subCell.options!.count - 1 {
                        optionStr += "\n"
                        startIndex += 1
                    }
                }
            }
            
            let fontSize = oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].titleFont?.size ?? 16
            
            let style = NSMutableParagraphStyle()
            if let alignment = oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].titleFont?.alignment {
                
                if alignment == "left" {
                    style.alignment = NSTextAlignment.left
                }else if alignment == "right" {
                    style.alignment = NSTextAlignment.right
                }else {
                    style.alignment = NSTextAlignment.center
                }
            }
            
            let attributedString = NSMutableAttributedString(string: optionStr, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
                 NSAttributedString.Key.paragraphStyle: style])
            
            if subCell.isRequired! {
                
                if rangeList.isEmpty {
                    key.text = optionStr
                }else {
                    for (index, range) in rangeList.enumerated() {
                        
                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: selectedColorList[index]) , range: range)
                    }
                    key.attributedText = attributedString
                }
                
            }else {
                key.text = optionStr
            }
            

        }else if subCell.subType == "singleChoice" {
            
            key.isEditable = false
            
            let recognizer = getSingleChoiceGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            key.addGestureRecognizer(recognizer)
            
            if subCell.textValue != "" {
                key.backgroundColor = .yellow
            }else {
                key.backgroundColor = .white
            }
            
        }else if subCell.subType == "sign" {
            
            key.isEditable = true
//            key.isHidden = true
            imageView.isHidden = false
            
        
            let recognizer = getSignGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            imageView.addGestureRecognizer(recognizer)
            
            keyTop.constant = imageHeight.constant
            keyHeight.constant = 40
            
            if isReadOnly {
                
                if let signUrl = subCell.fileUrl {
                    let fileUrl = URL(string: "https://appcloud.fpcetg.com.tw/eformapi/uploads/\(signUrl)")
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData = NSData(contentsOf: fileUrl!) {
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData as Data) {
                                    imageView.image = image
                                }
                            }
                        }
                    }
                    
//                    let fileUrl = URL(string: "https://appcloud.fpcetg.com.tw/eformapi/uploads/\(signUrl)")
//                    if let imageData = NSData(contentsOf: fileUrl!) {
//                        if let image = UIImage(data: imageData as Data) {
//                            imageView.image = image
//                        }
//                    }
                }
            }else {
                if let signUrl = subCell.fileUrl {
                    let fileURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!).appendingPathComponent(signUrl)
                    if let imageData = NSData(contentsOf: fileURL!) {
                        let image = UIImage(data: imageData as Data)
                        
                        imageView.image = image
                    }
                }
            }
            
            
            
            if subCell.textValue != "" {
                key.text = subCell.textValue
            }
        }else if subCell.subType == "picture" {
            key.isHidden = true
            imageView.isHidden = false
            
            let recognizer = getPictureGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            imageView.addGestureRecognizer(recognizer)
            
            if isReadOnly {
                if let signUrl = subCell.fileUrl {
                    let fileUrl = URL(string: "https://appcloud.fpcetg.com.tw/eformapi/uploads/\(signUrl)")
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData = NSData(contentsOf: fileUrl!) {
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData as Data) {
                                    imageView.image = image
                                }
                            }
                        }
                    }
                    
//                    let fileUrl = URL(string: "https://appcloud.fpcetg.com.tw/eformapi/uploads/\(signUrl)")
//                    if let imageData = NSData(contentsOf: fileUrl!) {
//                        if let image = UIImage(data: imageData as Data) {
//                            imageView.image = image
//                        }
//                    }
                }
            }else {
                if let signUrl = subCell.fileUrl, signUrl != "" {
                    let fileURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!).appendingPathComponent(signUrl)
                    if let imageData = NSData(contentsOf: fileURL!) {
                        let image = UIImage(data: imageData as Data)
                        
                        imageView.image = image
                    }
                }else {
                    imageView.image = nil
                }
            }
            
            
            
        }else if subCell.subType == "form" {
            
            key.isEditable = false
            
            let recognizer = getFormGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            key.addGestureRecognizer(recognizer)
        }else if subCell.subType == "textChoice" || subCell.subType == "textMultiChoice" || subCell.subType == "combineOption" {
            
            key.isEditable = false
            
            let recognizer = getTextChoiceGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            key.addGestureRecognizer(recognizer)
            
            if subCell.textValue != "" {
                
                if oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].fixedMessage != "" {
                    
                    key.text = "\(oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].fixedMessage ?? "")\n\(subCell.textValue ?? "")"
                }else {
                    key.text = subCell.textValue
                }
            }else {
                if oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].fixedMessage != "" {
                    
                    key.text = "\(oriFormDataList[formNumber!].cells[cellNumber].subCellDataList![subCellIndex].fixedMessage ?? "")"
                }
            }
            
            
        }else if subCell.subType == "copyButton" {
            key.isEditable = false
            
            let recognizer = getCopyButtonGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            key.addGestureRecognizer(recognizer)
            
        }else if subCell.subType == "deleteButton" {
            key.isEditable = false
            
            if subCell.isFirstCopyCell! {
                key.text = ""
            }else {
                let recognizer = getDeleteButtonGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
                
                key.addGestureRecognizer(recognizer)
            }
        }else if subCell.subType == "functionDropDown" {
            
            key.isEditable = false
            
            let recognizer = getFunctionDropDownGesture(index: formData.index!, formNumber: formNumber!, cellNumber: cellNumber)
            
            key.addGestureRecognizer(recognizer)
            
            if subCell.textValue != "" {
                for option in subCell.options! {
                    if option.id == subCell.textValue {
                        key.text = option.name
                        if subCell.isRequired! {
                            key.textColor = UIColor(hexString: option.color!)
                            
                        }
                    }
                }
            }
        }else if subCell.subType == "limitTextArea" {
            key.isScrollEnabled = true
            
            if subCell.textValue != "" {
                key.text = subCell.textValue
            }
            
            if let isNumber = subCell.textValue?.isDouble, isNumber {
                if let checkNumber = Double(subCell.textValue!) {
                    if checkNumber > subCell.maxValue ?? 0.0 || checkNumber < subCell.minValue ?? 0.0 {
                        key.textColor = UIColor(hexString: subCell.overLimitColor!)
                    }
                }
            }
        }
    }
    
    func setTableTextFieldDatePicker(type: String, index: Int, formNumber: Int, cellNumber: Int, subCellIndex: Int, key: UITextView) {
        let toolBar = UIToolbar()
        let formatter = DateFormatter()
        let datePicker:UIDatePicker = UIDatePicker()
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
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
        dateFormatter.index = subCellIndex
        dateFormatter.dateFormatter = formatter
        dateFormatter.datePicker = datePicker
        
//        formDataList[index].dateFormatterList.removeAll()
        
        formDataList[index].dateFormatterList.append(dateFormatter)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(subCellDoneButtonTapped))
        let cancelButton = UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(subCellCancelClick))
        toolBar.setItems([doneButton, cancelButton], animated: true)
        
        doneButton.tag = cellNumber
        doneButton.index = index
        doneButton.formNumber = formNumber
        doneButton.inputNumber = subCellIndex
        
        cancelButton.tag = cellNumber
        cancelButton.index = index
        cancelButton.formNumber = formNumber
        cancelButton.inputNumber = subCellIndex
        
        key.inputView = datePicker
        key.inputAccessoryView = toolBar
        
    }
    
    @objc func subCellCancelClick(sender: UIBarButtonItem) {
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.tag
        let subCellIndex = sender.inputNumber
        
        for dateFormatter in formDataList[index].dateFormatterList {
            print(dateFormatter.index)
            print(subCellIndex)
            if dateFormatter.index == subCellIndex {
                let timeInterval:TimeInterval = (dateFormatter.datePicker?.date.timeIntervalSince1970)!
                print(timeInterval)
                
                formDataList[index].subCellDataList![subCellIndex].textValue = ""
                
                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = ""
                
                if self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isRequired! && !self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isOptional! {
                    
                    self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = false
                }
                
            }
        }
        self.saveForm()
        self.tableView.reloadData()
        self.view.endEditing(true)
    }
    
    @objc func subCellDoneButtonTapped(sender: UIBarButtonItem) {
        // 依據元件的 tag 取得 UITextField
        self.chooseDateSelf = true
        
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.tag
        let subCellIndex = sender.inputNumber
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
        
        for dateFormatter in formDataList[index].dateFormatterList {
            if dateFormatter.index == subCellIndex {
                let timeInterval:TimeInterval = (dateFormatter.datePicker?.date.timeIntervalSince1970)!
                print(timeInterval)
                
                formDataList[index].subCellDataList![subCellIndex].textValue = String(dateFormatter.datePicker!.date.timeIntervalSince1970 * 1000).components(separatedBy: ".").first
                
                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = String(dateFormatter.datePicker!.date.timeIntervalSince1970 * 1000).components(separatedBy: ".").first
                
                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = true
            }
        }
        self.saveForm()
        self.tableView.reloadData()
        self.view.endEditing(true)
    }
    
    func getFunctionDropDownGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(functionDropDown))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func functionDropDown(_ sender: UITapGestureRecognizer) {
        
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
        
        let actionSheet = UIAlertController(title: "選項", message: nil, preferredStyle: .actionSheet)
        
        
        for option in formDataList[index].subCellDataList![subCellIndex].options! {
            let action = UIAlertAction(title: option.name, style: .default) { action in
                
                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = true
                
                if option.functionType == "label" {
                    self.formDataList[index].subCellDataList![subCellIndex].textValue = option.id
                    self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = option.id
                    
                    self.saveForm()
                    self.tableView.reloadData()
                }else if option.functionType == "textArea" {
                    let actionSheet = UIAlertController(title: "訊息提示", message: "請輸入數值", preferredStyle: .alert)
                    
                    actionSheet.addTextField { (textField) in
                        textField.keyboardType = .decimalPad
                    }

                    // 3. Grab the value from the text field, and print it when the user clicks OK.
                    actionSheet.addAction(UIAlertAction(title: "確定", style: .default, handler: { [weak actionSheet] (_) in
                        let textField = actionSheet?.textFields![0] // Force unwrapping because we know it exists.
                        
                        self.formDataList[index].subCellDataList![subCellIndex].textValue = textField!.text
                        self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = textField!.text
                        self.formDataList[index].subCellDataList![subCellIndex].title = textField!.text
                        self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].title = textField!.text
                        
                        self.saveForm()
                        self.tableView.reloadData()
                    }))
                    
                    actionSheet.addAction(UIAlertAction(title: "取消", style: .destructive))
                    
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                        let loc = sender.location(in: self.view)
                        actionSheet.modalPresentationStyle = .popover
                        actionSheet.popoverPresentationController?.sourceView = self.view
                        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: loc.x, y: loc.y, width: 1.0, height: 1.0)
                    }
                    
                    self.present(actionSheet, animated: true) {
                        print("option menu presented")
                    }
                }else if option.functionType == "form" {
                    self.formDataList[index].subCellDataList![subCellIndex].textValue = option.id
                    self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = option.id
                    
                    self.saveForm()
                    self.tableView.reloadData()
                    
                    if let subFormId = self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].subFormId {
                        self.toNewForm(subFormId: subFormId, formNumber: formNumber, cellNumber: cellNumber, subCellIndex: subCellIndex)
                        
                    }
                }
            
                
            }
            actionSheet.addAction(action)
        }
        
        let option = UIAlertAction(title: "取消", style: .destructive) { action in
            
//            self.formDataList[cellNumber].subCellDataList![subCellIndex].textValue = ""
//
//            self.oriFormData?.cells[cellNumber].subCellDataList![subCellIndex].textValue = ""
//
//            self.tableView.reloadData()
        }
        actionSheet.addAction(option)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            let loc = sender.location(in: self.view)
            actionSheet.modalPresentationStyle = .popover
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: loc.x, y: loc.y, width: 1.0, height: 1.0)
        }
        
        self.present(actionSheet, animated: true) {
            print("option menu presented")
        }
        
    }
    
    func getDropDownGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dropOption))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    
    @objc func dropOption(_ sender: UITapGestureRecognizer) {
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
        
        self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].loopIndex! += 1
        
        
        if (self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].loopIndex!) >= (self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].options?.count)! {
            self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].loopIndex! = 0
        }
        
        formDataList[index].subCellDataList![subCellIndex].title = formDataList[index].subCellDataList![subCellIndex].options! [(self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].loopIndex!)].name
        
        
        self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = formDataList[cellNumber].subCellDataList![subCellIndex].options! [(self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].loopIndex!)].id
        
        self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = true
        
        self.saveForm()
        tableView.reloadData()
    }
    
    func getTextChoiceGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(textChoiceOption))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func textChoiceOption(_ sender: UITapGestureRecognizer) {
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
        
        let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "DFSelectionVC") as? DFSelectionVC
        
        var optionList = [DynamicInput]()
        
        
        if let oriOptionList = formDataList[index].subCellDataList![subCellIndex].options, oriOptionList.count > 0 {
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
        
        if let defaultList = formDataList[index].subCellDataList![subCellIndex].choiceValue {
            vc?.defaultList = defaultList
        }
        
        vc?.type = self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].subType
        vc?.isOffline = true
        vc?.formNumber = formNumber
        vc?.cellNumber = cellNumber
        vc?.subCellNumber = subCellIndex
        vc?.id = (self.oriFormDataList[formNumber].cells[cellNumber].id)!
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
        
//        let actionSheet = UIAlertController(title: "選項", message: nil, preferredStyle: .actionSheet)


//        for option in formDataList[index].subCellDataList![subCellIndex].options! {
//            let action = UIAlertAction(title: option.name, style: .default) { action in
//
//                self.formDataList[index].subCellDataList![subCellIndex].textValue = option.name
//
//                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = option.name
//
//                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = true
//
//                self.saveForm()
//                self.tableView.reloadData()
//            }
//            actionSheet.addAction(action)
//        }
//
//        let option = UIAlertAction(title: "取消", style: .destructive) { action in
//
////            self.formDataList[cellNumber].subCellDataList![subCellIndex].textValue = ""
////
////            self.oriFormData?.cells[cellNumber].subCellDataList![subCellIndex].textValue = ""
////
////            self.tableView.reloadData()
//        }
//        actionSheet.addAction(option)
//
//        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
//            let loc = sender.location(in: self.view)
//            actionSheet.modalPresentationStyle = .popover
//            actionSheet.popoverPresentationController?.sourceView = self.view
//            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: loc.x, y: loc.y, width: 1.0, height: 1.0)
//        }
//
//        self.present(actionSheet, animated: true) {
//            print("option menu presented")
//        }
        
    }
    
    func getRadioGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(radioOption))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func radioOption(_ sender: UITapGestureRecognizer) {
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
        
        let actionSheet = UIAlertController(title: "選項", message: nil, preferredStyle: .actionSheet)
        
        
        for option in formDataList[index].subCellDataList![subCellIndex].options! {
            let action = UIAlertAction(title: option.name, style: .default) { action in
                
                self.formDataList[index].subCellDataList![subCellIndex].textValue = option.id
                
                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = option.id
                
//                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = true
                
                if self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isRequired! && !self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isOptional! {
                    
                    if self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue == "" {
                        self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = false
                    }else {
                        self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = true
                    }
                }
                
                self.saveForm()
                self.tableView.reloadData()
            }
            actionSheet.addAction(action)
        }
        
        let option = UIAlertAction(title: "取消", style: .destructive) { action in
            
//            self.formDataList[cellNumber].subCellDataList![subCellIndex].textValue = ""
//
//            self.oriFormData?.cells[cellNumber].subCellDataList![subCellIndex].textValue = ""
//
//            self.tableView.reloadData()
        }
        actionSheet.addAction(option)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            let loc = sender.location(in: self.view)
            actionSheet.modalPresentationStyle = .popover
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: loc.x, y: loc.y, width: 1.0, height: 1.0)
        }
        
        self.present(actionSheet, animated: true) {
            print("option menu presented")
        }
        
    }
    
    func getCheckBoxGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(checkBoxOption))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func checkBoxOption(_ sender: UITapGestureRecognizer) {
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
        
        let actionSheet = UIAlertController(title: "選項", message: nil, preferredStyle: .actionSheet)
        
        
        for option in formDataList[index].subCellDataList![subCellIndex].options! {
            let action = UIAlertAction(title: option.name, style: .default) { action in
                
                if let optionIndex = self.formDataList[index].subCellDataList![subCellIndex].choiceValue!.firstIndex(where: { (id) -> Bool in
                    return option.id == id
                }) {
                    self.formDataList[index].subCellDataList![subCellIndex].choiceValue!.remove(at: optionIndex)
                    self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].choiceValue!.remove(at: optionIndex)
                } else {
                    self.formDataList[index].subCellDataList![subCellIndex].choiceValue!.append(option.id!)
                    self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].choiceValue!.append(option.id!)
                }
                
                if self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isRequired! && !self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isOptional! {
                    
                    if self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].choiceValue!.isEmpty {
                        self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = false
                    }else {
                        self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = true
                    }
                }
                self.saveForm()
                self.tableView.reloadData()
            }
            actionSheet.addAction(action)
        }
        
        let option = UIAlertAction(title: "取消", style: .destructive) { action in
            
//            self.formDataList[cellNumber].subCellDataList![subCellIndex].textValue = ""
//
//            self.oriFormData?.cells[cellNumber].subCellDataList![subCellIndex].textValue = ""
//
//            self.tableView.reloadData()
        }
        actionSheet.addAction(option)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            let loc = sender.location(in: self.view)
            actionSheet.modalPresentationStyle = .popover
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: loc.x, y: loc.y, width: 1.0, height: 1.0)
        }
        
        self.present(actionSheet, animated: true) {
            print("option menu presented")
        }
        
    }
    
    func getSingleChoiceGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(singleChoice))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func singleChoice(_ sender: UITapGestureRecognizer) {
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
        
        if self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue == "" {
            self.formDataList[index].subCellDataList![subCellIndex].textValue = "Y"
            
            self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = "Y"
        }else {
            self.formDataList[index].subCellDataList![subCellIndex].textValue = ""
            
            self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = ""
        }
        
        self.saveForm()
        self.tableView.reloadData()
        
    }
    
    func getSignGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toSign))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func toSign(_ sender: UITapGestureRecognizer) {
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
    
        let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "DFElecSignVC") as? DFElecSignVC
        
        vc!.index = index
        vc!.formNumber = formNumber
        vc!.cellIndex = cellNumber
        vc!.subCellIndex = subCellIndex
        vc!.isFromSubCell = true
        vc!.signUrl = formDataList[index].subCellDataList![subCellIndex].fileUrl ?? ""
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        self.navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    func getPictureGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(openCameraOrPhoto))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func openCameraOrPhoto(_ sender: UITapGestureRecognizer) {
        
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //檢查裝置是否有相機功能
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "拍攝照片", style: .default) { action in
                picker.sourceType = .camera
                picker.allowsEditing = false
                picker.formNumber = formNumber
                picker.cellNumber = cellNumber
                picker.subCellNumber = subCellIndex
                
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
                picker.formNumber = formNumber
                picker.cellNumber = cellNumber
                picker.subCellNumber = subCellIndex
                
                self.present(picker, animated: true, completion: nil)
            }
            actionSheet.addAction(photoAction)
        }
        
        let viewAction = UIAlertAction(title: "預覽放大", style: .default) { action in
            
            let fileUrl = self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].fileUrl
            if let signUrl = fileUrl {
                let fileURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!).appendingPathComponent(signUrl)
                if let imageData = NSData(contentsOf: fileURL!) {
                    if let image = UIImage(data: imageData as Data) {
                        let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
                        let imageVC = storyboard.instantiateViewController(withIdentifier: "DFImageVC") as? DFImageVC
                        
                        imageVC?.imageIndex = 0
                        imageVC!.images.append(image)
                        
                        self.present(imageVC!, animated: true)
                    }
                }
            }
        }
        actionSheet.addAction(viewAction)
        
        let deleteAction = UIAlertAction(title: "刪除圖片", style: .default) { action in
            if let fileName = self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].fileUrl, fileName != "" {
                do {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    
                    // create the destination file url to save your image
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    
                    let fileManager = FileManager.default
                    try fileManager.removeItem(at: fileURL)
        
                    self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].fileUrl = ""
                    
                    self.saveForm()
                    self.tableView.reloadData()
                } catch {
                }
            }
        }
        actionSheet.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .destructive)
        
        actionSheet.addAction(cancelAction)
        
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            let loc = sender.location(in: self.view)
            actionSheet.modalPresentationStyle = .popover
            actionSheet.popoverPresentationController?.sourceView = self.view
            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: loc.x, y: loc.y, width: 1.0, height: 1.0)
        }
        self.present(actionSheet, animated: true) {
            print("option menu presented")
        }
    }
    
    func getFormGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(getForm))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func getForm(_ sender: UITapGestureRecognizer) {
        let index = sender.index
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
            
            return
        }
        
        if let subFormId = self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].subFormId {
            self.toNewForm(subFormId: subFormId, formNumber: formNumber, cellNumber: cellNumber, subCellIndex: subCellIndex)
            
        }
        
    }
    
    func toNewForm(subFormId: String, formNumber: Int, cellNumber: Int, subCellIndex: Int) {
        let storyboard = UIStoryboard.init(name: "DFMain", bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: "DFmainVC") as? DFmainVC
        
        vc?.isUsingJsonString = true
        vc?.formId = subFormId
        vc?.delegate = self.delegate
        vc?.mainFormDelegate = self
        vc?.jsonStringList = self.jsonStringList
        
        if let searchId =  self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].searchId, searchId != ""  {
    
            let searchTitleCellIndex = Int(searchId.split(separator: "_")[0])! - 1
            let searchTitleSubCellIndex = Int(searchId.split(separator: "_")[1])! - 1
            
            vc?.searchTitle = self.oriFormDataList[formNumber].cells[searchTitleCellIndex].subCellDataList![searchTitleSubCellIndex].title ?? ""
        }
        
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        if let tokenKey = tokenKey, tokenKey == "mobilefpcToken" {
            backItem.tintColor = .white
        }
        
        self.navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func getCopyButtonGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(copyCell))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func copyCell(_ sender: UITapGestureRecognizer) {
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        let subCellIndex = (sender.view?.tag)!
        
        let copyCellId = self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].copyCellId
        
        for cell in self.oriFormDataList[formNumber].cells {
            if cell.id == copyCellId {
                let copiedCell = getCopyCell(copyCell: cell, formNumber: formNumber)
                
                var maxIndex = 1
                
                for (index, cell) in self.oriFormDataList[formNumber].cells.enumerated() {
                    if copiedCell.copyId == cell.copyId {
                        maxIndex = index
                    }
                }
                
                self.oriFormDataList[formNumber].cells.insert(copiedCell, at: maxIndex + 1)
                break
            }
        }
        
        self.setFormData()
        
        self.saveForm()
        self.tableView.reloadData()
    }
    
    func getCopyCell(copyCell: cell, formNumber: Int) -> cell {
        let newCell = cell()
        
        let cellIndex = self.oriFormDataList[formNumber].cells.count + 1
        
        newCell.id = "\(cellIndex)"
        newCell.type = copyCell.type
        newCell.dataSource = copyCell.dataSource
        newCell.paramType = copyCell.paramType
        newCell.copyCellId = copyCell.copyCellId
        newCell.copyId = copyCell.copyId
        newCell.subCellDataList = []
        
        var copyIndex = 1
        
        for cell in self.oriFormDataList[formNumber].cells {
            if cell.copyId == copyCell.copyId {
                copyIndex += 1
            }
        }
        
        for (index, subCell) in copyCell.subCellDataList!.enumerated() {
            let newSubCell = subCellData()
            let subCellIndex = index + 1
            
            newSubCell.id = "\(cellIndex)_\(subCellIndex)"
            
            if subCell.isIncrement! {
                newSubCell.title = "\(copyIndex)"
            }else {
                newSubCell.title = subCell.title
            }
            
            newSubCell.subType = subCell.subType
            
            newSubCell.titleFont = subCell.titleFont
            
//            if index == copyCell.subCellDataList!.count - 1 {
//                newSubCell.subType = "deleteButton"
//                newSubCell.title = "刪除"
//                newSubCell.titleFont?.color = "#EA0000"
//            }
            
            newSubCell.width = subCell.width
            newSubCell.cellHeight = subCell.cellHeight
            newSubCell.cellGap = subCell.cellGap
            newSubCell.loopIndex = subCell.loopIndex
            newSubCell.textValue = ""
            newSubCell.options = subCell.options
            newSubCell.isHorizon = subCell.isHorizon
            newSubCell.isReserve = subCell.isReserve
            newSubCell.isRequired = subCell.isRequired
            newSubCell.isOptional = subCell.isOptional
            newSubCell.extra1 = subCell.extra1
            newSubCell.extra2 = subCell.extra2
            newSubCell.extra3 = subCell.extra3
            newSubCell.extra4 = subCell.extra4
            newSubCell.extra5 = subCell.extra5
            newSubCell.extra6 = subCell.extra6
            newSubCell.extra7 = subCell.extra7
            newSubCell.extra8 = subCell.extra8
            newSubCell.subFormId = subCell.subFormId
            newSubCell.dataSource = subCell.dataSource
            newSubCell.paramType = subCell.paramType
            newSubCell.dataId = subCell.dataId
            newSubCell.searchId = subCell.searchId
            newSubCell.copyCellId = subCell.copyCellId
            
            newSubCell.height = subCell.height
           
            newSubCell.choiceValue = []
            newSubCell.keyBoardType = subCell.keyBoardType
            newSubCell.borderColor = subCell.borderColor
            newSubCell.finishColor = subCell.finishColor
            newSubCell.isIncrement = subCell.isIncrement
            newSubCell.isFirstCopyCell = false
            
            newSubCell.fileUrl = ""
            newSubCell.isFinish = false
            
            newCell.subCellDataList?.append(newSubCell)
        }

        return newCell
    }
    
    func getDeleteButtonGesture(index: Int, formNumber: Int, cellNumber: Int) -> UITapGestureRecognizer{
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(deleteCell))
        
        recognizer.index = index
        recognizer.formNumber = formNumber
        recognizer.inputNumber = cellNumber
        
        
        return recognizer
    }
    
    @objc func deleteCell(_ sender: UITapGestureRecognizer) {
        let formNumber = sender.formNumber
        let cellNumber = sender.inputNumber
        
        let confirmSheet = UIAlertController(title: "訊息提示", message: "確定刪除？", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "確定", style: .default, handler: {
            action in
            let copyId = self.oriFormDataList[formNumber].cells[cellNumber].copyId
            
            self.oriFormDataList[formNumber].cells.remove(at: cellNumber)
            
            var index = 1
            
            for cell in self.oriFormDataList[formNumber].cells {
                if cell.copyId == copyId {
                    for subCell in cell.subCellDataList! {
                        if subCell.isIncrement! {
                            subCell.title = "\(index)"
                        }
                    }
                    index += 1
                }
            }
            
            self.setFormData()
            
            self.saveForm()
            self.tableView.reloadData()
        })
    
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: {
            action in
            
        })
        
        confirmSheet.addAction(confirmAction)
        confirmSheet.addAction(cancelAction)
        
        self.present(confirmSheet, animated: true, completion: nil)
        
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let formData = formDataList[indexPath.row]
        
        if formData.formType != "picture" , formData.formType != "attachment" {
            if let isReadOnly = formData.isReadOnly, isReadOnly {
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
                if formData.formNumber == data.formNumber, formData.cellNumber == data.cellNumber {
                    data.isCheck = false
                }
            }
            
            self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].choiceValue?.removeAll()
            self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].choiceValue?.append(formData.optionNumber!)
            
            self.saveForm()
            
            formData.isCheck = true
            
            tableView.reloadData()
        case "checkbox":
            
            if formData.isCheck {
                self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].choiceValue =  self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].choiceValue?.filter({$0 != formData.optionNumber})
            }else {
                self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].choiceValue?.append(formData.optionNumber!)
            }
            
            formData.isCheck = !formData.isCheck
            
            self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].choiceValue = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].choiceValue?.sorted(by: {$0 < $1})
            
            self.saveForm()
            
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
                        if imageFormData.formId == formData.formId, imageFormData.formNumber == formData.formNumber, imageFormData.cellNumber == formData.cellNumber {
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
            
            if let actions = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].actions {
                if actions.count > 0{
                    vc?.urlString = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].actions![0].url
                }
            }
            
            if let oriOptionList = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].options, oriOptionList.count > 0 {
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
            vc?.formNumber = formData.formNumber!
            vc?.cellNumber = formData.cellNumber!
            vc?.id = (self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].id)!
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
            
            if let actions = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].actions {
                if actions.count > 0{
                    vc?.urlString = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].actions![0].url
                }
            }
            
            if let oriOptionList = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].options {
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
            
            if let oriOptionList = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].dynamicField {
                vc?.chosenItemList = oriOptionList
            }
            
            if !optionList.isEmpty {
                vc?.isFilter = true
            }
            
            vc?.type = formData.formType
            vc?.formNumber = formData.formNumber!
            vc?.cellNumber = formData.cellNumber!
            vc?.id = (self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].id)!
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
                    picker.cellNumber = formData.cellNumber!
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
                    picker.cellNumber = formData.cellNumber!
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
                importMenu.cellNumber = formData.cellNumber!
                
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
            
            vc?.formNumber = formData.formNumber!
            vc?.cellIndex = formData.cellNumber!
            vc?.signUrl = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].fileUrl ?? ""
            
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
            
            if isUsingJsonString {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                // create the destination file url to save your image
                let fileURL = documentsDirectory.appendingPathComponent(imageName)
                
                print(fileURL)
                
                if let fileName = self.oriFormDataList[picker.formNumber].cells[picker.cellNumber].subCellDataList![picker.subCellNumber].fileUrl, fileName != "" {
                    do {
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        
                        // create the destination file url to save your image
                        let fileURL = documentsDirectory.appendingPathComponent(fileName)
                        
                        let fileManager = FileManager.default
                        try fileManager.removeItem(at: fileURL)
            
                    } catch {
                    }
                }
                
                
                self.oriFormDataList[picker.formNumber].cells[picker.cellNumber].subCellDataList![picker.subCellNumber].fileUrl = imageName
                
                
                self.saveForm()
                if let imageData = image.rotateImageByOrientation().jpegData(compressionQuality: 0.9) {
                    do {


                        try imageData.write(to: fileURL)
                        
                        self.tableView.reloadData()
                        print("file saved")
                    } catch {
                        print("error saving file:", error)
                    }
                }
               
            }else {
                dfShowActivityIndicator()
                customUpload(oriImage: image, fileUrl: nil, fileName: imageName, formNumber: picker.formNumber, cellNumber: picker.cellNumber, type: "picture")
            }
            
        }
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.formNumber = documentMenu.formNumber
        documentPicker.cellNumber = documentMenu.cellNumber
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    //選擇檔案後上傳
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        dfShowActivityIndicator()
        customUpload(oriImage: nil, fileUrl: url, fileName: url.lastPathComponent, formNumber: controller.formNumber, cellNumber: controller.cellNumber, type: "attachment")
    }
    
    func customUpload(oriImage: UIImage?, fileUrl: URL?, fileName: String, formNumber: Int, cellNumber: Int, type: String) {
        
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
                            
                            self.oriFormDataList[formNumber].cells[cellNumber].fileList?.append(fileData)
                            
                            for (index, file) in self.formDataList.enumerated() {
                                if formNumber == file.formNumber, cellNumber == file.cellNumber {
                                    let fileData = FormData()
                                    fileData.formNumber = formNumber
                                    fileData.cellNumber = cellNumber
                                    fileData.title = fileName
                                    fileData.inputNumber = self.oriFormDataList[formNumber].cells[cellNumber].fileList!.count - 1
                                    fileData.formType = type
                                    fileData.mainType = "upload"
                                    fileData.formId = "\(self.oriFormDataList[formNumber].cells[cellNumber].fileList!.count - 1)"
                                    fileData.image = oriImage
                                    fileData.fileUrl = (data["fileurl"] as! String)
                                    fileData.isReadOnly = false
                                    self.formDataList.insert(fileData, at: index + (self.oriFormDataList[formNumber].cells[cellNumber].fileList?.count)!)
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
            if formData.formNumber! == data.formNumber, formData.cellNumber == data.cellNumber {
                let inputField = FormData()
                
                inputField.index = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].count! + 1
                inputField.formNumber = formData.formNumber!
                inputField.cellNumber = formData.cellNumber!
                inputField.inputNumber = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].count
                
                inputField.formType = formType
                inputField.mainType = formData.formType
                inputField.isReadOnly = false
                scrollIndex = index + self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].count! + 1
                formDataList.insert(inputField, at: scrollIndex)
                break
            }
        }
        let dynamicValue = DynamicInput()
        dynamicValue.id = UUID().uuidString
        dynamicValue.name = ""
        self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].dynamicField?.append(dynamicValue)
        self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].count = self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].count! + 1
        
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
        let formNumber = textField.tag
        let cellNumber = textField.cellIndex
        let inputNumber = textField.inputNumber
        
        for formData in formDataList {
            if formData.formType == "textField" {
                if formData.mainType == "dynamicTextField", formNumber == formData.formNumber {
                    formData.inputValue = textField.text!
                    self.oriFormDataList[formNumber].cells[cellNumber].dynamicField?[inputNumber].name = textField.text!
                }else {
                    if  formNumber == formData.formNumber, formData.cellNumber == cellNumber {
                        formData.inputValue = textField.text!
                        self.oriFormDataList[formNumber].cells[cellNumber].textValue = textField.text!
                    }
                }
            }
        }
        
        self.saveForm()
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        
        let signleCellIndex = textView.signleCellIndex
        let signleInputIndex = textView.signleInputIndex
        
        let formNumber = textView.formNumber
        let subCellIndex = textView.tag
        let cellNumber = textView.inputNumber
        
        for formData in formDataList {
            if formData.formType == "textArea" {
                if formData.mainType == "dynamicTextArea", formNumber == formData.formNumber {
                    formData.inputValue = textView.text!
                    self.oriFormDataList[formNumber].cells[signleCellIndex].dynamicField?[signleInputIndex].name = textView.text!
                }else {
                    if formNumber == formData.formNumber {
                        formData.inputValue = textView.text!
                        self.oriFormDataList[formNumber].cells[signleCellIndex].textValue = textView.text!
                    }
                }
            }else if formData.formType == "tableKey" {
                if formData.cellNumber == cellNumber, formData.formNumber == formNumber {
                    formData.subCellDataList![subCellIndex].textValue = textView.text!
                    
                    self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue = textView.text!
                }
            }
        }
        
        self.saveForm()
    }
    
    //檢查是否有必填欄位，且是否已完成
    func checkConditionIsFinish(index: Int, formNumber: Int, cellIndex: Int, subCellIndex: Int) -> Bool {
        var isFinish = true
        
        let needFinishIdList = self.oriFormDataList[formNumber].cells[cellIndex].subCellDataList![subCellIndex].needConditionIdList ?? []
        
        for needFinishId in needFinishIdList {
            for form in self.oriFormDataList {
                for cell in form.cells {
                    for subCell in cell.subCellDataList! {
                        if subCell.conditionID == needFinishId {
                            if !subCell.isFinish! {
                                isFinish = false
                                break
                            }
                        }
                    }
                }
            }
        }
        
        
        return isFinish
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        let index = textView.index
        let formNumber = textView.formNumber
        let cellNumber = textView.inputNumber
        let subCellIndex = textView.tag
        
        let txtFieldPosition = textView.convert(textView.bounds.origin, to: tableView)
        let indexPath = tableView.indexPathForRow(at: txtFieldPosition)
        if let ip = indexPath {
            tableView.scrollToRow(at: ip, at: .bottom, animated: true)
        }
        
        if !checkConditionIsFinish(index: index, formNumber: formNumber, cellIndex: cellNumber, subCellIndex: subCellIndex) {
            
            DFUtil.DFTipMessageAndConfirm(self, msg: self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].tip ?? "", callback: {
                _ in
                self.view.endEditing(true)
            })
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        let index = textView.index
        let formNumber = textView.formNumber
        let cellNumber = textView.inputNumber
        let subCellIndex = textView.tag
        let width = textView.width
        
        if width != 0 {
            adjustTextView(textView, layout: false, width: width, cellNumber: index, index: subCellIndex)
        }
        
        if self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isRequired! && !self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isOptional! {
            if self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].textValue == "" {
                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = false
            }else {
                self.oriFormDataList[formNumber].cells[cellNumber].subCellDataList![subCellIndex].isFinish = true
            }
        }
        
        
        self.tableView.reloadData()
    }
    
    func adjustTextView(_ textView: UITextView, layout: Bool, width: CGFloat, cellNumber: Int, index: Int) {
        
        let fixedWidth = width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        
        var hh:CGFloat = 0
        if newSize.height > 100 {
            hh = 100
        } else if newSize.height < 40 {
            hh = 40
        } else {
            hh = newSize.height
        }
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: hh)
        textView.frame = newFrame;
        
        formDataList[cellNumber].subCellDataList![index].height = hh

        
        self.tableView.reloadData()
//        if layout == true {
//            self.tableView.reloadData()
//        }
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
                
                if !selectionVC.isOffline {
                    for formData in formDataList {
                        if formData.formType == "multipleSelection", formData.formNumber == selectionVC.formNumber, formData.cellNumber == selectionVC.cellNumber, formData.formId == selectionVC.id {
                            
                            self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].dynamicField = []
                            
    //                        self.oriFormData?.cells[formData.formNumber!].dynamicField = []
                            
                            formData.dynamicField = []
                            for option in selectionVC.chosenItemList {
                                formData.dynamicField?.append(option)
                                self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].dynamicField?.append(option)
                                
    //                            self.oriFormData?.cells[formData.formNumber!].dynamicField?.append(option)
                            }
                        }else if formData.formType == "singleSelection", formData.formNumber == selectionVC.formNumber, formData.cellNumber == selectionVC.cellNumber, formData.formId == selectionVC.id {
                            
                            self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].dynamicField = []
                            
    //                        self.oriFormData?.cells[formData.formNumber!].dynamicField = []
                            formData.dynamicField = []
                            for option in selectionVC.chosenItemList {
                                formData.dynamicField?.append(option)
                                self.oriFormDataList[formData.formNumber!].cells[formData.cellNumber!].dynamicField?.append(option)
                                
    //                            self.oriFormData?.cells[formData.formNumber!].dynamicField?.append(option)
                            }
                        }
                    }
                }else {
                    let subType = self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].subType
                    
                    if !selectionVC.chosenItemList.isEmpty {
                        
                        if subType == "textChoice" {
                            
                            let option = selectionVC.chosenItemList[0]
                            
                            self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].textValue = option.name
                            
                            self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].extra1 = option.id
                            self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].isFinish = true
                            
                        }else if subType == "textMultiChoice"{
                            var joinTitle = ""
                            var joinId = ""
                            
                            for (index, chosenItem) in selectionVC.chosenItemList.enumerated() {
                                joinTitle += chosenItem.name ?? ""
                                joinId += chosenItem.id ?? ""
                                
                                if index != selectionVC.chosenItemList.count - 1 {
                                    joinTitle += ";"
                                    joinId += ";"
                                }
                                
                                if !self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].isHorizon! {
                                    joinTitle += "\n"
                                }
                            }
                            
                            if selectionVC.selfInputText != "" {
                                joinTitle += selectionVC.selfInputText

                                if !self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].isHorizon! {
                                    joinTitle += "\n"
                                }
                            }
                            
                            self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].textValue = joinTitle
                            
                            self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].extra1 = joinId
                            self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].isFinish = true
                            
                        }else if subType == "combineOption" {
                            let chosenItem = selectionVC.chosenItemList[0]
                            
                            var foundIndex = 0
                            
                            for (index, option) in self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].options!.enumerated() {
                                if option.id == chosenItem.id {
                                    foundIndex = index
                                    break
                                }
                            }
                            
                            for subCell in self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList! {
                                if subCell.subType == "combineOption" {
                                    
                                    if foundIndex <= subCell.options!.count - 1 {
                                        subCell.textValue = subCell.options![foundIndex].name
                                        subCell.extra1 = subCell.options![foundIndex].id
                                        subCell.isFinish = true
                                    }
                                }
                            }
                        }
                    }else if selectionVC.selfInputText != "" {
                        self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].textValue = selectionVC.selfInputText.trimmingCharacters(in: .whitespaces)

                        self.oriFormDataList[selectionVC.formNumber].cells[selectionVC.cellNumber].subCellDataList![selectionVC.subCellNumber].isFinish = true
                    }
                    
                    self.saveForm()
                }
                
                
                
                self.tableView.reloadData()
                
            }
        }else if segue.source is DFElecSignVC {
            if let elecSignVC = segue.source as? DFElecSignVC {
                if !elecSignVC.isFromSubCell {
                    for formData in formDataList {
                        if formData.formType == "sign", formData.formNumber == elecSignVC.formNumber, formData.cellNumber == elecSignVC.cellIndex  {
                            
                            self.oriFormDataList[elecSignVC.formNumber].cells[elecSignVC.cellIndex].fileUrl = elecSignVC.signUrl
                            
                            break
                        }
                    }
                    
                }else {
                    formDataList[elecSignVC.index].subCellDataList![elecSignVC.subCellIndex].fileUrl = elecSignVC.signUrl
                    
                    self.oriFormDataList[elecSignVC.formNumber].cells[elecSignVC.cellIndex].subCellDataList![elecSignVC.subCellIndex].fileUrl = elecSignVC.signUrl
                    
                    self.oriFormDataList[elecSignVC.formNumber].cells[elecSignVC.cellIndex].subCellDataList![elecSignVC.subCellIndex].isFinish = true

                }
            }
        }
        
        self.saveForm()
        self.tableView.reloadData()
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
