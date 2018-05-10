//
//  SNPnotificationBar.swift
//  Pods-SNPnotificationBar_Tests
//
//  Created by Ahmad Almasri on 5/10/18.
//

import Foundation
import UIKit

public class NotificationBarConfiguration {
    
    
    public var duration: TimeInterval
    
    public var font: UIFont
    
    public var textColor: UIColor
    
    public var padding: CGFloat
    
    public var warningColor: UIColor
    
    public var successColor: UIColor
    
    public var errorColor: UIColor
    
    public var infoColor: UIColor

    init() {
        duration = 4.0
        font = UIFont.systemFont(ofSize: 16.0)
        textColor = .white
        padding = 4.0
        warningColor = #colorLiteral(red: 0.8941176471, green: 0.6901960784, blue: 0, alpha: 1)
        successColor = #colorLiteral(red: 0.3607843137, green: 0.6431372549, blue: 0.137254902, alpha: 1)
        errorColor = #colorLiteral(red: 0.7764705882, green: 0.05490196078, blue: 0.07450980392, alpha: 1)
        infoColor = #colorLiteral(red: 0.1725490196, green: 0.6470588235, blue: 0.7960784314, alpha: 1)
    }
}

public enum NotificationBarStyle {
    
    case warning, success, error , info , custom(VisualConfig)
    
    
    public struct VisualConfig {
        let backgroundColor: UIColor
        let dismiss: NotificationBarDismiss
        
        public init(backgroundColor: UIColor, dismiss: NotificationBarDismiss) {
            self.backgroundColor = backgroundColor
            self.dismiss = dismiss
        }
    }
    
    func config() -> VisualConfig {
        switch self {
        case .warning:
            return VisualConfig(backgroundColor: SNPnotificationBar.sharedConfig.warningColor,
                                dismiss: .manual)
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

public enum NotificationBarDismiss {
    case manual, auto
}

public class SNPnotificationBar{
    
    public static let sharedConfig = NotificationBarConfiguration()
    
    private var presenter: UIViewController? = nil
    private var text: String
    private let style: NotificationBarStyle
    private let onDismiss: (() -> ())?
    private var view: UIView!
    
    
    public init(_ presenter: UIViewController? = nil,
                text: String,
                style: NotificationBarStyle,
                onDismiss: (() -> ())? = nil) {
       
        
        self.presenter = presenter
        self.text = text
        self.style = style
        self.onDismiss = onDismiss
        setupPresenter()
        setupView()
        subscribeForRotationChanges()
    }
    
  
    private func setupPresenter(){
        
        if self.presenter == nil {
            self.presenter = getTopController()
        }
    }
  private func getTopController()->UIViewController?{
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
 
            return topController
        }
        fatalError("top Controller is nil")
    }
    
    public func show() {
        animateIn()
    }
    
    public func dismiss() {
        animateOut(withDelay: 0)
    }
    
    private func setupView() {
        
        let width = presenter?.view.frame.width
        let height = SNPnotificationBar.sharedConfig.padding + textHeight()
        view = UIView(frame: CGRect(x: 0,
                                    y: -height,
                                    width: width ?? 0.0,
                                    height: height))
        view?.backgroundColor = style.config().backgroundColor
        view?.alpha = 0
        presenter?.view.addSubview(view)
        
        setupLabel()
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
            self.view.center.y += self.view.frame.height
        }, completion: nil)
        
        if style.config().dismiss == .auto {
            animateOut(withDelay: SNPnotificationBar.sharedConfig.duration)
        }
    }
    
    private func animateOut(withDelay delay: TimeInterval) {
        UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut, animations: {
            self.view.alpha = 0
            self.view.center.y -= self.view.frame.height
        }, completion: { _ in
            self.view.removeFromSuperview()
            self.onDismiss?()
        })
    }
    
    
    private func textHeight() -> CGFloat {
        let font = SNPnotificationBar.sharedConfig.font
        let size = (text as NSString).size(withAttributes: [.font: font])
        let lines = Int(size.width / (presenter?.view.frame.width ?? 0))
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

