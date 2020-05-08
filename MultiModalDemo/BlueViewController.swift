//
//  BlueViewController.swift
//  MultiModalDemo
//
//  Created by Mike Mayer on 5/8/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

protocol BlueViewDelegate
{
  func completed(_ bvc:BlueViewController, n1:Int, n2:Int)
  func clicked(_ bvc:BlueViewController, button:Int, count:Int )
}

class BlueViewController: UIViewController, ManagedViewController
{
  @IBOutlet weak var managedView : UIView!
  
  @IBOutlet weak var button1 : UIButton!
  @IBOutlet weak var button2 : UIButton!
  
  var container   : MultiModalViewController?
  var delegate    : BlueViewDelegate?
  
  var n : [Int] = [0, 0]
  
  override func awakeFromNib() {
    super.awakeFromNib()
    debug("RedVC: managed = \(self.managedView)")
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    debug("blue will appear: \(n[0]) \(n[1])")
    n[0] = 0
    n[1] = 0
    
    managedView.layer.cornerRadius = 30
    managedView.layer.masksToBounds = true
    managedView.layer.borderColor = UIColor.blue.cgColor
    managedView.layer.borderWidth = 2
  }
  
  @IBAction func green(_ sender:UIButton)
  {
    debug("go green")
  }
  
  @IBAction func red(_ sender:UIButton)
  {
    debug("go red")
  }
  
  @IBAction func handleClick(_ sender:UIButton)
  {
    delegate?.clicked(self, button: sender.tag, count: n[sender.tag-1]);
    n[sender.tag - 1] = n[sender.tag - 1] + 1
  }
  
  @IBAction func bye(_ sender:UIButton)
  {
    debug("bye")
    self.dismiss(animated: true) {
      debug("blue dismissed")
    }
  }
  
  @IBAction func ok(_ sender:UIButton)
  {
    delegate?.completed(self, n1: n[0], n2: n[1])
    
    self.dismiss(animated: true) {
      debug("blue complete")
    }
  }

}