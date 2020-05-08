//
//  GreenViewController.swift
//  MultiModalDemo
//
//  Created by Mike Mayer on 5/8/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

class GreenViewController: UIViewController, ManagedViewController
{
  @IBOutlet weak var managedView : UIView!
  @IBOutlet weak var okButton : UIButton!
  
  var container   : MultiModalViewController?
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    managedView.layer.cornerRadius = 10
    managedView.layer.masksToBounds = true
    managedView.layer.borderColor = UIColor.green.cgColor
    managedView.layer.borderWidth = 2
  }
  
  @IBAction func blue(_ sender:UIButton)
  {
    container?.present("blue")
  }
  
  @IBAction func red(_ sender:UIButton)
  {
    container?.present("red")
  }
  
  @IBAction func handleSwitch(_ sender:UISwitch)
  {
    okButton.isHidden = sender.isOn
  }
  
  @IBAction func bye(_ sender:UIButton)
  {
    self.dismiss(animated: true) {
      debug("green dismissed")
    }
  }

}
