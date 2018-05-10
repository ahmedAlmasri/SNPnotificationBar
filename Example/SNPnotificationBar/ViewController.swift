//
//  ViewController.swift
//  SNPnotificationBar
//
//  Created by ahmedAlmasri on 05/10/2018.
//  Copyright (c) 2018 ahmedAlmasri. All rights reserved.
//

//
//  SNPnotificationBar.swift
//  Pods-SNPnotificationBar_Tests
//
//  Created by Ahmad Almasri on 5/10/18.
//

import Foundation
import UIKit

public class SNPnotificationBarConfiguration {
    
    
    public var duration: TimeInterval
    
    public var font: UIFont
    
    public var textColor: UIColor
    
    public var padding: CGFloat
    
    public var margin: CGFloat

    public var warningColor: UIColor
    
    public var successColor: UIColor
    
    public var errorColor: UIColor
    
    public var infoColor: UIColor
    
    public var cornerRadius:CGFloat
    
    init() {
        duration = 4.0
        font = UIFont.systemFont(ofSize: 16.0)
        textColor = .white
        padding = 4.0
        warningColor = #colorLiteral(red: 0.8941176471, green: 0.6901960784, blue: 0, alpha: 1)
        successColor = #colorLiteral(red: 0.3607843137, green: 0.6431372549, blue: 0.137254902, alpha: 1)
        errorColor = #colorLiteral(red: 0.7764705882, green: 0.05490196078, blue: 0.07450980392, alpha: 1)
        infoColor = #colorLiteral(red: 0.1725490196, green: 0.6470588235, blue: 0.7960784314, alpha: 1)
        cornerRadius = 0
        margin = 0
    }
}

public enum SNPnotificationBarStyle {
    
    case warning, success, error , info , custom(VisualConfig)
    
    
    public struct VisualConfig {
        let backgroundColor: UIColor
        let dismiss: SNPnotificationBarDismiss
        
        public init(backgroundColor: UIColor, dismiss: SNPnotificationBarDismiss) {
            self.backgroundColor = backgroundColor
            self.dismiss = dismiss
        }
    }
    
    func config() -> VisualConfig {
        switch self {
        case .warning:
            return VisualConfig(backgroundColor: SNPnotificationBar.sharedConfig.warningColor,
                                dismiss: .auto)
        case .success:
            return VisualConfig(backgroundColor: SNPnotificationBar.sharedConfig.successColor,
                                dismiss: .auto)
        case .error:
            return VisualConfig(backgroundColor: SNPnotificationBar.sharedConfig.errorColor,
                                dismiss: .auto)
        case .info:
            return VisualConfig(backgroundColor: SNPnotificationBar.sharedConfig.infoColor,
                                dismiss: .auto)
        case .custom(let style):
            return style
        }
    }
}

public enum SNPnotificationBarDismiss {
    case manual, auto
}

public enum SNPnotificationBarPosition {
    case top, bottom
}

public class SNPnotificationBar{
    
    public static let sharedConfig = SNPnotificationBarConfiguration()
    
    private var presenter: UIViewController
    private var text: String
    private let style: SNPnotificationBarStyle
    private let onDismiss: (() -> ())?
    private var view: UIView!
    private var position:SNPnotificationBarPosition
    
    public init(_ presenter: UIViewController,
                text: String,
                style: SNPnotificationBarStyle,
                position:SNPnotificationBarPosition = .top,
                onDismiss: (() -> ())? = nil) {
        
        
        self.presenter = presenter
        self.text = text
        self.style = style
        self.onDismiss = onDismiss
        self.position = position
        setupView()
        subscribeForRotationChanges()
    }
    
    public func show() {
        animateIn()
    }
    
    public func dismiss() {
        animateOut(withDelay: 0)
    }
    
    private func setupView() {
        let margin = SNPnotificationBar.sharedConfig.margin
        let width = presenter.view.frame.width
        let height = SNPnotificationBar.sharedConfig.padding + textHeight()
        
        view = UIView(frame: CGRect(x: margin,
                                    y: (-height+margin),
                                    width: (width - (margin*2)),
                                    height: height))
        
        setupPosition()
        view?.backgroundColor = style.config().backgroundColor
        view?.alpha = 0
        view.clipsToBounds = true
        view.layer.cornerRadius = SNPnotificationBar.sharedConfig.cornerRadius
        presenter.view.addSubview(view)
        
        setupLabel()
    }
    
    func setupPosition(){
        let margin = SNPnotificationBar.sharedConfig.margin
        let height = SNPnotificationBar.sharedConfig.padding + textHeight()
        
        switch self.position {
        case .top:
            view.frame.origin.y = (-height+margin)
            break
        case .bottom:
            view.frame.origin.y =   (UIScreen.main.bounds.height - (height+margin))
            break
        }
    }
    private func setupLabel() {
        
        let padding = SNPnotificationBar.sharedConfig.padding
        let font = SNPnotificationBar.sharedConfig.font
        let textColor = SNPnotificationBar.sharedConfig.textColor
        
        let label = UILabel(frame: CGRect(origin: CGPoint(x: padding / 2,
                                                          y: padding / 2),
                                          size: CGSize(width: view.bounds.width - padding,
                                                       height: view.bounds.height - padding)))
        label.text = text
        label.font = font
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = textColor
        view.addSubview(label)
    }
    
    
    
    private func animateIn() {
        

        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.alpha = 1
            if self.position == .top {
                self.view.center.y += (self.view.frame.height )
            }else if self.position == .bottom {
                self.view.frame.origin.y -=  SNPnotificationBar.sharedConfig.margin //(self.view.frame.height )
            }
        }, completion: nil)
        
        if style.config().dismiss == .auto {
            animateOut(withDelay: SNPnotificationBar.sharedConfig.duration)
        }
    }
    
    private func animateOut(withDelay delay: TimeInterval) {

        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut, animations: {
            self.view.alpha = 0
            if self.position == .top {
            self.view.center.y -= (self.view.frame.height )
            }else if self.position == .bottom {
                self.view.center.y += (self.view.frame.height )
            }
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.onDismiss?()
        })
    }
    
    
    private func textHeight() -> CGFloat {
        let font = SNPnotificationBar.sharedConfig.font
        let size = (text as NSString).size(withAttributes: [.font: font])
        let lines = Int(size.width / (presenter.view.frame.width ))
        return 50.0 + CGFloat(lines) * size.height
    }
    
    
    private func subscribeForRotationChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRotation),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    @objc private func handleRotation() {
        setupView()
        animateIn()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


import UIKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SNPnotificationBar.sharedConfig.cornerRadius = 5
        SNPnotificationBar.sharedConfig.margin = 60
//        SNPnotificationBar.sharedConfig.padding = 100
        SNPnotificationBar.init(self, text: "test", style: .success,position: .bottom).show()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

