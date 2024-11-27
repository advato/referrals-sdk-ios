

import UIKit

/// A UIButton that allows users to share their referral link.
/// On tap, this button copies the referral URL to the clipboard, opens a `UIActivityViewController` to share the referral link,
/// and sends a request to track the button tap event.
/// Some of the button's properties, such as background color, title text, border color, font, and border width,
/// are configured by the SDK.
public final class ReferralButton: UIButton {
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                alpha = 0.75
            } else {
                UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
                    self.alpha = 1
                }.startAnimation()
            }
        }
    }
}

private extension ReferralButton {
    func setup() {
        addConfigUpdateObserver()
        setupUI()
        addTarget(self, action: #selector(showSharePopup), for: .touchUpInside)
    }
    
    func addConfigUpdateObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setupUI),
            name: .ReferralSDKConfigUpdated,
            object: nil
        )
    }
    
    @objc
    func setupUI() {
        let config = ReferralSDK.shared.configuration.button
        backgroundColor = UIColor(hexString: config.hexBackgroundColor)
        setTitleColor(UIColor(hexString: config.hexTitleColor), for: .normal)
        layer.borderColor = UIColor(hexString: config.hexBorderColor).cgColor
        setTitle(config.title, for: .normal)
        layer.borderWidth = config.borderWidth
        titleLabel?.font = UIFont.systemFont(ofSize: config.fontSize)
    }
    
    @objc
    func showSharePopup() {
        guard let refCode = ReferralSDK.shared.referralCode,
              let token = ReferralSDK.shared.entryPoint?.accessToken,
              let refUrl = URL(string: "https://adva.to/welcome?code=\(refCode)&token=\(token)") else {
            let errorPopup = PopupView()
            errorPopup.show(
                title: "Oops!",
                subtitle: "Could not share a link",
                isErrorMessage: true
            )
            return
        }
        ReferralSDK.shared.trackShareButtonTap()
        UIPasteboard.general.url = refUrl
        let activityController = UIActivityViewController(
            activityItems: [refUrl],
            applicationActivities: nil
        )
        UIApplication.shared.topViewController?.present(activityController, animated: true)
    }
}
