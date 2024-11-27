

import UIKit

final class PopupView: UIView {
    private let overlayViewController: UIViewController = {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        viewController.modalPresentationStyle = .overFullScreen
        return viewController
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.textColor = UIColor(hexString: config.hexTextColor)
        label.font = UIFont.boldSystemFont(ofSize: config.titleFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 5
        label.textColor = UIColor(hexString: config.hexTextColor)
        label.font = UIFont.systemFont(ofSize: config.subtitleFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let config = ReferralSDK.shared.configuration.popup
    private let usesErrorTextColor = false
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var topConstraint: NSLayoutConstraint?
    private var maxY: CGFloat = 0
    private var dismissalWorkItem: DispatchWorkItem?
    
    init() {
        super.init(frame: .zero)
        setup()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(
        title: String,
        subtitle: String,
        isErrorMessage: Bool = false
    ) {
        guard let topViewController = UIApplication.shared.topViewController else { return }
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        if isErrorMessage {
            subtitleLabel.textColor = UIColor(hexString: config.hexErrorTextColor)
        }
        
        overlayViewController.view.addSubview(self)
        overlayViewController.view.layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: overlayViewController.view.leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: overlayViewController.view.trailingAnchor, constant: -20),
        ])
        
        topConstraint = topAnchor.constraint(
            equalTo: overlayViewController.view.safeAreaLayoutGuide.topAnchor,
            constant: -250
        )
        topConstraint?.isActive = true
        
        topViewController.present(overlayViewController, animated: false) { [self] in
            animateIn()
            startDismissalTimer()
        }
    }
}

private extension PopupView {
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(hexString: config.hexBackgroundColor)
        layer.cornerRadius = 15
        clipsToBounds = true
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
    
    func startDismissalTimer() {
        dismissalWorkItem?.cancel()
        dismissalWorkItem = DispatchWorkItem { [weak self] in
            self?.animateOut()
        }
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.dismissalDelay,
            execute: dismissalWorkItem!
        )
    }
    
    func animateIn() {
        topConstraint?.constant = Constants.topConstraintConstant
        UIView.animate(
            withDuration: Constants.animationDuration,
            delay: 0,
            options: [.curveEaseOut]
        ) {
            self.superview?.layoutIfNeeded()
        } completion: { completed in
            if completed {
                self.maxY = self.frame.maxY + Constants.topConstraintConstant
            }
        }
    }
    
    func animateOut() {
        topConstraint?.constant = -250
        UIView.animate(
            withDuration: Constants.animationDuration,
            delay: 0,
            options: [.curveEaseIn]
        ) {
            self.superview?.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
            self.overlayViewController.dismiss(animated: false)
        }
    }
    
    @objc
    func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        let velocity = gesture.velocity(in: superview)
        let percentage = gesture.location(in: superview).y / maxY
        
        switch gesture.state {
        case .began:
            dismissalWorkItem?.cancel()
            
        case .changed:
            topConstraint?.constant = min(
                max(
                    Constants.topConstraintConstant + translation.y,
                    -250
                ),
                Constants.topConstraintConstant * 3
            )
            superview?.layoutIfNeeded()
            
        case .ended, .cancelled:
            startDismissalTimer()
            if velocity.y < -100 || percentage < 0.5 {
                animateOut()
            } else {
                topConstraint?.constant = Constants.topConstraintConstant
                UIView.animate(withDuration: Constants.animationDuration) {
                    self.superview?.layoutIfNeeded()
                }
            }
            
        default:
            break
        }
    }
}

// MARK: - Constants
private extension PopupView {
    struct Constants {
        static let topConstraintConstant: CGFloat = 20
        static let animationDuration: Double = 0.3
        static let dismissalDelay: Double = 5
    }
}
