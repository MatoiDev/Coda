//
//  KeyboardAccessoryManager.swift
//  AccessoryKit
//
//  Created by Erast on 16/04/23.
//

import UIKit

/// Class to set up keyboard accessory responsively. Uses `UITextInputView` on iPhone (a toolbar above virtual keyboard) and
/// `UITextInputAssistantItem` on iPad (embedded inside the floating keyboard toolbar).
///
/// Note:
/// - Instance of this class should be retained by the parent view controller.
public class KeyboardAccessoryManager {

    // MARK: - Private properties

    private let keyButtons: [KeyboardAccessoryButton]
    private let keyMargin: CGFloat
    private let keyWidth: CGFloat
    private let keyHeight: CGFloat
    private let keyCornerRadius: CGFloat
    private let showDismissKeyboardKey: Bool
    private weak var delegate: KeyboardAccessoryViewDelegate?

    // MARK: - Initializer

    /// Initializes an instance of `KeyboardAccessoryManager`.
    /// - Parameters:
    ///   - keyButtons: An array of `KeyboardAccessoryButton` model to construct the keys.
    ///   - keyWidth: The width of each key inside input accessory view.
    ///   - keyHeight: The height of each key inside input accessory view.
    ///   - keyCornerRadius: The corner radius of each key inside input accessory view.
    ///   - keyMargin: The margin between keys inside input accessory view.
    ///   - showDismissKeyboardKey: If show the dismiss keyboard key on the right of scrollable area.
    ///   - delegate: Delegate object that implements `KeyboardAccessoryViewDelegate`.
    public init(keyButtons: [KeyboardAccessoryButton] = [],
                keyWidth: CGFloat = KeyboardAccessoryView.defaultKeyWidth,
                keyHeight: CGFloat = KeyboardAccessoryView.defaultKeyHeight,
                keyCornerRadius: CGFloat = KeyboardAccessoryView.defaultKeyCornerRadius,
                keyMargin: CGFloat = KeyboardAccessoryView.defaultKeyMargin,
                showDismissKeyboardKey: Bool = true,
                delegate: KeyboardAccessoryViewDelegate? = nil) {
        self.keyButtons = keyButtons
        self.keyMargin = keyMargin
        self.keyWidth = keyWidth
        self.keyHeight = keyHeight
        self.keyCornerRadius = keyCornerRadius
        self.showDismissKeyboardKey = showDismissKeyboardKey
        self.delegate = delegate
    }

    // MARK: - Public APIs

    /// Configures a `UITextView` with accessory manager instance. Uses `UITextInputView` on iPhone
    /// (a toolbar above virtual keyboard) and `UITextInputAssistantItem` on iPad (embedded inside
    /// the floating keyboard toolbar).
    /// - Parameter textView: The text view instance to be configured.
    public func configure(textView: UITextView) {
        if Self.isIPad {
            configure(inputAssistantItem: textView.inputAssistantItem)
        } else {
            textView.inputAccessoryView = makeInputView()
        }
    }

    /// Creates an instance of toolbar view that can be assigned to the text view's `inputAccessoryView`.
    /// - Returns: The keyboard accessory view instance.
    public func makeInputView() -> KeyboardAccessoryView {
        return KeyboardAccessoryView(
            keyWidth: keyWidth,
            keyHeight: keyHeight,
            keyCornerRadius: keyCornerRadius,
            keyMargin: keyMargin,
            keyButtons: keyButtons,
            showDismissKeyboardKey: showDismissKeyboardKey,
            delegate: delegate)
    }

    /// Configures the `UITextInputAssistantItem` with given accessory manager.
    /// - Parameter inputAssistantItem: The `UITextInputAssistantItem` to be configured.
    public func configure(inputAssistantItem: UITextInputAssistantItem) {
        var leadingButtons: [UIBarButtonItem] = []
        var trailingButtons: [UIBarButtonItem] = []
        var overflowMenuActions: [UIAction] = []

        for button in keyButtons {
            if button.position == .overflow {
                guard let title = button.title else {
                    fatalError("[AccessoryKit] Overflow button must have a title")
                }
                let action = UIAction(
                    title: title,
                    image: button.image,
                    handler: { handler in
                        button.tapHandler?()
                    })
                overflowMenuActions.append(action)
            } else {
                let buttonItem = UIBarButtonItem(
                    title: button.title,
                    image: button.image,
                    primaryAction: UIAction(handler: { handler in
                        button.tapHandler?()
                    }),
                    menu: button.menu)
                if button.position == .leading {
                    leadingButtons.append(buttonItem)
                } else {
                    trailingButtons.append(buttonItem)
                }
            }
        }

        if !overflowMenuActions.isEmpty {
            let moreButton = UIBarButtonItem(
                title: "More",
                image: UIImage(systemName: "ellipsis.circle"),
                menu: UIMenu(children: overflowMenuActions))
            trailingButtons.append(moreButton)
        }

        if showDismissKeyboardKey {
            let dismissButton = UIBarButtonItem(
                title: "Dismiss Keyboard",
                image: UIImage(systemName: "keyboard.chevron.compact.down"),
                primaryAction: UIAction(handler: { [weak self] handler in
                    self?.dismissButtonTapped()
                }))
            trailingButtons.append(dismissButton)
        }

        if !leadingButtons.isEmpty {
            let leadingGroup = UIBarButtonItemGroup(
                barButtonItems: leadingButtons,
                representativeItem: nil)
            inputAssistantItem.leadingBarButtonGroups = [leadingGroup]
        }

        if !trailingButtons.isEmpty {
            let trailingGroup = UIBarButtonItemGroup(
                barButtonItems: trailingButtons,
                representativeItem: nil)
            inputAssistantItem.trailingBarButtonGroups = [trailingGroup]
        }
    }

    // MARK: - Private

    @objc
    private func dismissButtonTapped() {
        delegate?.dismissKeyboardButtonTapped?()
    }

    private static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

}
