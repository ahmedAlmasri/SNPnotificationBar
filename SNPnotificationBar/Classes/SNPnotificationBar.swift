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
    
    fileprivate var topSafeArea: CGFloat
    fileprivate var isShow = false
    
    
    fileprivate var marginSafeArea: CGFloat {
        
        return  margin + topSafeArea
    }
    
    
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
        topSafeArea = 0
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
    private var associatedImageView:UIImageView!
    private var image:UIImage?
    private var imageColor:UIColor?
    private var label:UILabel!
    private let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
    
    private  var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    
    private var topSafeArea: CGFloat!
    private var bottomSafeArea: CGFloat!
    public init(_ presenter: UIViewController,
                text: String,
                style: SNPnotificationBarStyle,
                image: UIImage? = nil,
                imageColor:UIColor? = nil ,
                onDismiss: (() -> ())? = nil) {
        
        self.image = image
        self.imageColor = imageColor
        self.presenter = presenter
        self.text = text
        self.style = style
        self.onDismiss = onDismiss
        self.position = .top
        
        if #available(iOS 11.0, *) {
            if self.hasTopNotch {
                topSafeArea =  UIApplication.shared.keyWindow?.safeAreaInsets.top
                bottomSafeArea = presenter.view.safeAreaInsets.bottom
            }else {
                topSafeArea = 0
                bottomSafeArea = 0
            }
        } else {
            topSafeArea = 0
            bottomSafeArea = 0
        }
        
        
        SNPnotificationBar.sharedConfig.topSafeArea = topSafeArea
        
        
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
        let margin = SNPnotificationBar.sharedConfig.marginSafeArea
        let width = presenter.view.frame.width
        let height = SNPnotificationBar.sharedConfig.padding + textHeight()
        view = UIView(frame: CGRect(x: 0,
                                    y: (-height+margin),
                                    width: (width),
                                    height: height))
        
        
        
        setupPosition()
        view?.backgroundColor = style.config().backgroundColor
        view?.alpha = 0
        view.clipsToBounds = true
        view.layer.cornerRadius = SNPnotificationBar.sharedConfig.cornerRadius
        
        UIApplication.shared.keyWindow?.addSubview(view)
        
        //   presenter.view.addSubview(view)
        // setupConstraints()
        
        // setupAssociatedImage()
        setupLabel()
        
        
        if image != nil {
            //CGRect(origin: CGPoint(x: SNPnotificationBar.sharedConfig.padding - 10, y: view.frame.height/2), size: CGSize(width: 20.0, height: 20.0))
            
            let img = image?.withRenderingMode(.alwaysTemplate)
            let padding = SNPnotificationBar.sharedConfig.padding
            associatedImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 12,
                                                                            y: padding / 2),
                                                            size: CGSize(width: 40,
                                                                         height: 40)))
            associatedImageView.center = self.label.center
            associatedImageView.frame.origin.x = 12
            associatedImageView.image = img
            associatedImageView.tintColor = self.imageColor
            view.addSubview(associatedImageView!)
        }
    }
    func setupConstraints() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: presenter.view!.leadingAnchor, constant: 0).isActive = true
        
        view.trailingAnchor.constraint(equalTo:  presenter.view!.trailingAnchor, constant: 0).isActive = true
        if #available(iOS 11.0, *) {
            view.topAnchor.constraint(equalTo: presenter.view!.safeAreaLayoutGuide.topAnchor,    constant: 0).isActive = true
        } else {
            view.topAnchor.constraint(equalTo: presenter.view!.topAnchor,    constant: 0).isActive = true
        }
        
        view.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        // view.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        
    }
    func setupPosition(){
        let margin = SNPnotificationBar.sharedConfig.marginSafeArea
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
        
        label = UILabel(frame: CGRect(origin: CGPoint(x: (padding / 2) < 54 ? 54 : (padding / 2) ,
                                                      y: padding / 2),
                                      size: CGSize(width: view.bounds.width - (((padding / 2) < 54 ? 54 : (padding / 2)) * 2),
                                                   height: view.bounds.height - padding)))
        label.text = text
        label.font = font
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = textColor
        view.addSubview(label)
    }
    private func setupAssociatedImage() {
        associatedImageView?.frame = CGRect(origin: CGPoint(x: SNPnotificationBar.sharedConfig.padding - 10, y: view.frame.height/2), size: CGSize(width: 20.0, height: 20.0))
    }
    
    
    private func animateIn() {
        
        statusBar.isHidden = true
        
        if !SNPnotificationBar.sharedConfig.isShow {
            SNPnotificationBar.sharedConfig.isShow  = true
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.alpha = 1
                if self.position == .top {
                    self.view.center.y += (self.view.frame.height)
                }else if self.position == .bottom {
                    self.view.frame.origin.y -=  SNPnotificationBar.sharedConfig.marginSafeArea //(self.view.frame.height )
                }
            }, completion: nil)
            
            if style.config().dismiss == .auto {
                animateOut(withDelay: SNPnotificationBar.sharedConfig.duration)
            }
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
            
            //    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            
            SNPnotificationBar.sharedConfig.isShow  = false
            self.statusBar.isHidden = false
            
            //   })
            
        })
    }
    
    
    private func textHeight() -> CGFloat {
        let font = SNPnotificationBar.sharedConfig.font
        let size = (text as NSString).size(withAttributes: [.font: font])
        let lines = Int(size.width / (presenter.view.frame.width ))
        return 60.0 + CGFloat(lines) * size.height
    }
    
    
    private func subscribeForRotationChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRotation),
                                               name: UIDevice.orientationDidChangeNotification,
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
