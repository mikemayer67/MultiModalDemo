//
//  RedViewController.swift
//  MultiModalDemo
//
//  Created by Mike Mayer on 5/8/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

protocol RedViewDelegate
{
  func completed(_ rvc:RedViewController, x1:Float, y1:Float, x2:Float, y2:Float)
  func updated(_ rvc:RedViewController, slider:Int, value:Float )
}

class RedViewController: UIViewController, ManagedViewController
{
  @IBOutlet weak var managedView : UIView!
  
  @IBOutlet weak var slider1 : UISlider!
  @IBOutlet weak var slider2 : UISlider!
  @IBOutlet weak var slider3 : UISlider!
  @IBOutlet weak var slider4 : UISlider!
  
  var container   : MultiModalViewController?
  var delegate    : RedViewDelegate?
  
  override func viewWillAppear(_ animated: Bool)
  {
    super.viewWillAppear(animated)
    managedView.layer.cornerRadius = 20
    managedView.layer.masksToBounds = true
    managedView.layer.borderColor = UIColor.red.cgColor
    managedView.layer.borderWidth = 1
  }
  
  @IBAction func green(_ sender:UIButton)
  {
    container?.present("green")
  }
  
  @IBAction func blue(_ sender:UIButton)
  {
    container?.present("blue")
  }
  
  @IBAction func handleChange(_ sender:UISlider)
  {
    delegate?.updated(self, slider: sender.tag, value: sender.value)
  }
  
  @IBAction func bye(_ sender:UIButton)
  {
    self.dismiss(animated: true) {
      debug("red dismissed")
    }
  }
  
  @IBAction func ok(_ sender:UIButton)
  {
    delegate?.completed(self, x1: slider1.value, y1: slider2.value, x2: slider3.value, y2: slider4.value)
    
    self.dismiss(animated: true) {
      debug("red complete")
    }
  }

}
