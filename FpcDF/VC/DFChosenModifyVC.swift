//
//  ChosenModifyVC.swift
//  DynamicForm
//
//  Created by 陳仲堯 on 2019/12/26.
//  Copyright © 2019 陳仲堯. All rights reserved.
//

import UIKit

class DFChosenModifyVC: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var oriChosenItemList = [DynamicInput]()
    var chosenItemList = [DynamicInput]()
    var timer: Timer?
    var searchBarTextString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "KeyValueCell", bundle: Bundle(for: FpcDF.self)), forCellReuseIdentifier: "KeyValueCell")

        let modify = UIBarButtonItem(title: "確認修改" , style: UIBarButtonItem.Style.plain, target: self, action: #selector(confirm))
        
        self.navigationItem.rightBarButtonItems = [modify]
    }
    
    @objc func confirm(sender: AnyObject) {
        self.performSegue(withIdentifier: "toSelectionVC", sender: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let t = timer {
            t.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(doSearch), userInfo: nil, repeats: false)
        
        searchBarTextString = searchText
        
    }
    
    @objc func doSearch() {
        if searchBarTextString != "" {
            let parameters = [
                "keywords" : searchBarTextString
            ]
            
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chosenItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: KeyValueCell = tableView.dequeueReusableCell(withIdentifier: "KeyValueCell", for: indexPath) as! KeyValueCell
        
        let option = chosenItemList[indexPath.row]
        
        let checkTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(checkTap))
        
        cell.imageConstraint?.constant = 25
        
        if option.isSelected! {
            cell.checkIcon.image = UIImage(named: "icon_checksign_checked", in: Bundle(for: FpcDF.self), compatibleWith: nil)
        }else {
            cell.checkIcon.image = UIImage(named: "icon_checksign_unchecked", in: Bundle(for: FpcDF.self), compatibleWith: nil)
        }
       
        cell.checkIcon.addGestureRecognizer(checkTapRecognizer)
        
        cell.checkIcon.tag = indexPath.row
        
        DFUtil.setKeyValueData(cell: cell, keyValueArray: option.keyValueArray!)
        
        return cell
    }

    @objc func checkTap(sender:UITapGestureRecognizer) {
        let indexPath = IndexPath(row: (sender.view?.tag)!, section: 0)
        let choseOption = oriChosenItemList[(sender.view?.tag)!]
        let cell: KeyValueCell = tableView.cellForRow(at: indexPath) as! KeyValueCell
        
        choseOption.isSelected = !choseOption.isSelected!
        
        if choseOption.isSelected! {
            cell.checkIcon.image = UIImage(named: "icon_checksign_checked", in: Bundle(for: FpcDF.self), compatibleWith: nil)
            chosenItemList.append(choseOption)
        }else {
            cell.checkIcon.image = UIImage(named: "icon_checksign_unchecked", in: Bundle(for: FpcDF.self), compatibleWith: nil)
            
            for (index, option) in chosenItemList.enumerated() {
                if option.id == choseOption.id {
                    chosenItemList.remove(at: index)
                    break
                }
            }
        }
        
//        if !chosenItemList.isEmpty {
//            total.text = "\(chosenItemList.count)"
//            let form = UIBarButtonItem(title: "確認(\(chosenItemList.count))" , style: UIBarButtonItem.Style.plain, target: self, action: #selector(toFormVC))
//            //        saveFile!.image = UIImage(named: "top_save_button")
//
//            self.navigationItem.rightBarButtonItems = [form]
//        }else {
//            self.navigationItem.rightBarButtonItems = [confirm!]
//        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

    }

}
