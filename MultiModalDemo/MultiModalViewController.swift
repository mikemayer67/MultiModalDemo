//
//  MultiModalViewController.swift
//  MultiModalDemo
//
//  Created by Mike Mayer on 5/6/20.
//  Copyright © 2020 VMWishes. All rights reserved.
//

import UIKit

/**
Protocol that must be implemented by any UIViewController that would be
 managed by a **MultiModalViewController**
 
 When implementing a UIViewController that conforms to this protocol, you will need to add the content
 to be displayed as a subview of the root view.
 
 MultiModalViewController uses the root view of your UIViewController soley for determining the location to present your managed view.
 The root view is **not** displayed.
 */
protocol ManagedViewController : UIViewController
{
  /// The view to be managed by *MultiModalViewController*
  var managedView : UIView!                   { get }
  
  /// The *MultiModalViewController* that is presenting the view
  ///
  /// This property is set by the presenting *MultiModalViewController*.  You should not set or modify this value.
  var container   : MultiModalViewController? { get set }
}

/**
 Protocol that defines the methods that a *MultiModalViewController* delegate must implement
 
 This delegate provide methods for creating and configuring UIViewControllers that conform to the *ManagedViewController* protocol.
 */
protocol MultiModalDelegate
{
  /**
   Creates a UIViewController that conforms to *ManagedViewController* for the specified identifier.
   
   This method is invoked if the *MultiModalViewController* is asked to present the *ManagedViewController* associated with the specified identifier that the *MultiModalViewController* does not current manage.
   
   If this method returns nil, the *MultiModalViewController* will attempt to load the view controller from storyboard
   */
  func viewController(_ identifier:String, for container:MultiModalViewController) -> ManagedViewController?
  
  /**
   Invoked after a *ManagedViewController* is added to the *MultiModalViewController*.
   
   This method is useful for finalizing configuration of view controllers that were loaded from storyboard.
   
   It could, for example, be used to add a delegate to the managed view controller to handle user interaction.
   */
  func configure(_ vc:ManagedViewController, for container:MultiModalViewController)
}

/**
 Container view controller for presenting a modal view controller over the current view.
 
 It's primary purpose is providing smooth transitions between presented modal view controllers.
 
 # Presented Modal Views #
 
 * Only one is shown at a time
 
 * Must conform to *ManagedViewController*
  
 # Background #
 
 The container view is presented over the current view controller.  This means that its root view controls visibility of the prior view
  
 * If *MultiModalViewController* is created using a storyboard, the root view defines the background.
 
 * If *MultiModalViewController* is created progromatically, the background color and alpha may be specified in the initializer.
 */
class MultiModalViewController : UIViewController
{
  var delegate : MultiModalDelegate?
    
  private var managedViewControllers = [String:ManagedViewController]()
  
  private(set) var current  : ManagedViewController?
  
  init(color:UIColor = .gray, alpha:CGFloat = 0.75)
  {
    super.init(nibName: nil, bundle: nil)
    view.backgroundColor = color.withAlphaComponent(alpha)
  }
  
  required init?(coder: NSCoder)
  {
    super.init(coder: coder)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    assert( current != nil, "No current managed view specified" )
    super.viewWillAppear(animated)
    if current == nil { self.dismiss(animated: true); return }
  }
  
  func add(_ vc:ManagedViewController, for key:String)
  {
    managedViewControllers[key] = vc
    vc.container = self
    vc.view.backgroundColor = UIColor.clear
    
    if let oldVC = current, oldVC == vc { present(vc) }
  }
  
  func viewController(for key:String) -> ManagedViewController?
  {
    if let vc = managedViewControllers[key] { return vc }
    
    guard let vc = delegate?.viewController(key, for:self)
      ?? storyboard?.instantiateViewController(identifier: key) as? ManagedViewController
      ?? UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: key) as? ManagedViewController
      else { return nil }
    
    vc.view.backgroundColor = UIColor.clear
    
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
      if newVC == oldVC { return }
      
      addChild(newVC)
      newVC.view.frame = self.view.frame
      self.view.addSubview(newVC.view)
      newVC.didMove(toParent: self)
      
      guard let oldView = oldVC.managedView else { assertionFailure("oldVC missing managed view"); return  }
      guard let newView = newVC.managedView else { assertionFailure("newVC missing managed view"); return  }
         
      newVC.view.setNeedsLayout()
      newVC.view.layoutIfNeeded()
                
      let oldFrame = oldView.frame
      let newFrame = newView.frame
      
      let wfac = newFrame.width / oldFrame.width
      let hfac = newFrame.height / oldFrame.height
      let scale = CATransform3DMakeScale( wfac, hfac, 1.0 )

      let oldX = oldFrame.origin.x + 0.5*oldFrame.size.width
      let oldY = oldFrame.origin.y + 0.5*oldFrame.size.height
      let newX = newFrame.origin.x + 0.5*newFrame.size.width
      let newY = newFrame.origin.y + 0.5*newFrame.size.height
      let shift = CATransform3DMakeTranslation(newX-oldX, newY-oldY, 0.0)
         
      newView.layer.transform = scale.invert.concat(shift.invert)
      newView.alpha = 0.0
             
      UIView.animate(withDuration: 0.5, animations: {
        oldView.layer.transform = scale.concat(shift)
        oldView.alpha = 0.0
        newView.layer.transform = CATransform3DIdentity
        newView.alpha = 1.0
      }) { (finished) in
        if finished
        {
          oldVC.willMove(toParent: nil)
          oldVC.view.removeFromSuperview()
          oldVC.removeFromParent()
          
          oldView.layer.transform = CATransform3DIdentity
          oldView.alpha = 1.0
        }
        else
        {
          newVC.willMove(toParent: nil)
          newVC.view.removeFromSuperview()
          newVC.removeFromParent()
          
          newView.layer.transform = CATransform3DIdentity
          newView.alpha = 1.0
        }
      }
      
    }
    else
    {
      addChild(newVC)
      newVC.view.frame = self.view.frame
      self.view.addSubview(newVC.view)
      newVC.didMove(toParent: self)
    }
    current = newVC
  }
  
}

extension CATransform3D
{
  func concat(_ t:CATransform3D) -> CATransform3D
  { return CATransform3DConcat(self, t) }
  
  var invert : CATransform3D
  { return CATransform3DInvert(self) }
}
