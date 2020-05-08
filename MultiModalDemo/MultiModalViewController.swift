//
//  MultiModalViewController.swift
//  MultiModalDemo
//
//  Created by Mike Mayer on 5/6/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit


protocol ManagedViewController : UIViewController
{
  var managedView : UIView!                   { get }
  var container   : MultiModalViewController? { get set }
}

protocol MultiModalDelegate
{
  func viewController(_ identifier:String, for container:MultiModalViewController) -> ManagedViewController?
  func configure(_ vc:ManagedViewController, for container:MultiModalViewController)
}

class MultiModalViewController : UIViewController
{
  var delegate : MultiModalDelegate?
    
  private var managedViewControllers = [String:ManagedViewController]()
  
  private(set) var current : ManagedViewController?
  
  init(color:UIColor? = nil,opacity:CGFloat? = nil)
  {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder)
  {
    super.init(coder: coder)
  }
  
  func add(_ vc:ManagedViewController, for key:String)
  {
    managedViewControllers[key] = vc
    vc.container = self
    
    if let oldVC = current, oldVC == vc { present(vc) }
  }
  
  func viewController(for key:String) -> ManagedViewController?
  {
    if let vc = managedViewControllers[key] { return vc }
    
    guard let vc = delegate?.viewController(key, for:self) ??
      storyboard?.instantiateViewController(identifier: key) as? ManagedViewController
      else { return nil }
    
    vc.container = self
    delegate?.configure(vc, for: self)
    
    managedViewControllers[key] = vc

    return vc
  }
  
  func present(_ key:String)
  {
    guard let newVC = viewController(for:key) else {
      assertionFailure("No view controller defined for key=\(key)")
      return
    }
    
    present(newVC)
  }
  
  func present(_ newVC:ManagedViewController)
  {
    if let oldVC = current
    {
      
    }
    else
    {
      addChild(newVC)
      newVC.managedView.frame = self.view.frame
      self.view.addSubview(newVC.managedView)
      newVC.didMove(toParent: self)
    }
  }
  
}
