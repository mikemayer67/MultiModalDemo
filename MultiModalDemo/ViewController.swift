//
//  ViewController.swift
//  MultiModalDemo
//
//  Created by Mike Mayer on 5/8/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

func debug(_ args:Any ...)  { print("DEBUG:",args) }

class ViewController: UIViewController
{
  @IBOutlet weak var modalSelector: UISegmentedControl!

  @IBAction func justDoIt(_ sender: UIButton)
  {
    var id : String?
    switch modalSelector.selectedSegmentIndex
    {
    case 0: id = "red"
    case 1: id = "blue"
    case 2: id = "green"
    default: return
    }
            
    var mmvc : MultiModalViewController!
    switch sender.tag
    {
    case 1: mmvc = storyboard?.instantiateViewController(identifier: "mmvc") as? MultiModalViewController
    case 2: mmvc = MultiModalViewController()
    case 3: mmvc = MultiModalViewController(color: #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1), alpha: 0.50)
    default:break
    }
    
    guard mmvc != nil else { return }
    
    mmvc.delegate = self
    mmvc.present(id!)
    
    mmvc.modalTransitionStyle = .crossDissolve
    mmvc.modalPresentationStyle = .overFullScreen
    
    present(mmvc, animated: true)
  }
}

extension ViewController : RedViewDelegate
{
  func completed(_ rvc: RedViewController, x1: Float, y1: Float, x2: Float, y2: Float) {
    debug("Red completed: (\(x1),\(y1))  (\(x2),\(y2))")
  }
  
  func updated(_ rvc: RedViewController, slider: Int, value: Float) {
    debug("Red updated \(slider): \(value)")
  }
}


extension ViewController : BlueViewDelegate
{
  func completed(_ bvc: BlueViewController, n1: Int, n2: Int) {
    debug("Blue completed: \(n1) \(n2)")
  }
  
  func clicked(_ bvc: BlueViewController, button: Int, count: Int) {
    debug("Blue clicked \(button): \(count)")
  }
}

extension ViewController : MultiModalDelegate
{
  func viewController(_ identifier: String, for container: MultiModalViewController) -> ManagedViewController?
  {
    guard let vc = container.storyboard?.instantiateViewController(identifier: identifier) as? ManagedViewController
      else { return nil }
    
    self.configure(vc, for: container)
    
    return vc
  }
  
  func configure(_ vc: ManagedViewController, for container: MultiModalViewController)
  {
    if      let rvc = vc as? RedViewController  { rvc.delegate = self }
    else if let bvc = vc as? BlueViewController { bvc.delegate = self }
  }
  
  
}
