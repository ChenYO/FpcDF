//
//  FpcDF.swift
//  FpcDF
//
//  Created by 陳仲堯 on 2020/1/17.
//  Copyright © 2020 陳仲堯. All rights reserved.
//

import UIKit

public class DynamicForm: UIViewController {

    public static func createForm(urlString: String, tokenURL: String, accessToken: String, tokenKey: String) -> DFmainVC {
        //        let vc = UIStoryboard(name: "DFMain", bundle: nil).instantiateViewController(withIdentifier : "mainVC") as? DFmainVC
        
        
        let storyboard = UIStoryboard.init(name: "DFMain", bundle: Bundle(for: DynamicForm.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "DFmainVC") as? DFmainVC
        
        vc!.urlString = urlString
        vc!.tokenURL = tokenURL
        vc!.accessToken = accessToken
        vc!.tokenKey = tokenKey
        
        return vc!
        
    }

}
