//
//  SwiftViewController.swift
//  ObjcSystemService_Example
//
//  Created by Computer  on 25/03/26.
//  Copyright © 2026 crazyLuobo. All rights reserved.
//

import UIKit
import ObjcSystemService

class SwiftViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
        
        let systemService = SystemService()
        
        if let deviceInfo = systemService.deviceInfo() as? [String:Any]{
            print(deviceInfo)
        }else{
            print("failure")
        }
       
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
