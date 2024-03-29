//
//  KeyboardAccessoryButton.swift
//  AccessoryKit
//
//  Created by Erast on 16/04/23.
//

import UIKit

/// Internal subview class that is represented by view model `KeyboardAccessoryButton`.
class KeyboardAccessoryButtonView: UIView {

    private let button = UIButton()
    private let viewModel: KeyboardAccessoryButton
    private let viewSize: CGSize

    init(viewModel: KeyboardAccessoryButton,
         width: CGFloat,
         height: CGFloat,
         cornerRadius: CGFloat) {
        self.viewModel = viewModel
        viewSize = CGSize(width: width, height: height)
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))

        addSubview(button)

        /// Show either image or title, but don't show both.
        if let image = viewModel.image {
            var configuration = UIButton.Configuration.filled()
            configuration.image = image
            configuration.imagePadding = -32
            configuration.title = ""
            button.contentHorizontalAlignment = .fill
            button.contentVerticalAlignment = .fill
            button.configuration = configuration
            button.backgroundColor = .clear
            button.tintColor = .clear

//            button.setImage(image, for: .normal)
        } else {
            button.setTitle(viewModel.title, for: .normal)
            button.backgroundColor = .secondarySystemBackground
            button.tintColor = viewModel.tintColor
        }

     
        button.setTitleColor(viewModel.tintColor, for: .normal)

        if let font = viewModel.font {
            button.titleLabel?.font = font
            
        }
        
      


   
    
        button.clipsToBounds = true
        button.layer.cornerRadius = cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)


        ])

        if let menu = viewModel.menu {
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
            return
        }

        if viewModel.tapHandler != nil {
            button.addTarget(self, action: #selector(tapHandlerAction), for: .touchUpInside)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func tapHandlerAction() {
        viewModel.tapHandler?()
    }

    // MARK: - APIs

    override var intrinsicContentSize: CGSize {
        return viewSize
    }

    override var tintColor: UIColor! {
        didSet {
            button.tintColor = tintColor
            button.setTitleColor(tintColor, for: .normal)
        }
    }

    var isEnabled: Bool {
        set {
            button.isEnabled = newValue
        }
        get {
            button.isEnabled
        }
    }

}
