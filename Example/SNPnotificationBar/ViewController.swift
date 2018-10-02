//
//  ViewController.swift
//  SNPnotificationBar
//
//  Created by ahmedAlmasri on 05/10/2018.
//  Copyright (c) 2018 ahmedAlmasri. All rights reserved.
//
import Foundation
import UIKit
import SNPnotificationBar
class ViewController: UIViewController {
    @IBOutlet weak var padinngValue: UISlider!
    @IBOutlet weak var marginValue: UISlider!
    @IBOutlet weak var cornerRadiusValue: UISlider!
    @IBOutlet weak var isTopSwirch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
    }


    @IBAction func infoTapped(_ sender:UIButton){
        
        configView()
        SNPnotificationBar.init(self, text: "Hello world! :) ", style: .info ,position: isTopSwirch.isOn ?  .top : .bottom).show()
        
    }
    @IBAction func errorTapped(_ sender:UIButton){
        configView()
       SNPnotificationBar.init(self, text: "Hello world! :) ", style: .error ,position: isTopSwirch.isOn ?  .top : .bottom).show()
    }
    @IBAction func warningTapped(_ sender:UIButton){
        configView()
      SNPnotificationBar.init(self, text: "Hello world! :) ", style: .warning ,position: isTopSwirch.isOn ?  .top : .bottom).show()
    }
    @IBAction func successTapped(_ sender:UIButton){
        configView()
    SNPnotificationBar.init(self, text: "Hello world! :) ", style: .success ,position: isTopSwirch.isOn ?  .top : .bottom).show()
    }
    
    func configView(){
        SNPnotificationBar.sharedConfig.cornerRadius = CGFloat(cornerRadiusValue.value)
        SNPnotificationBar.sharedConfig.margin = CGFloat(marginValue.value)
        SNPnotificationBar.sharedConfig.padding = CGFloat(padinngValue.value)
        
    }
}

