

import UIKit

extension UIApplication {
    var topViewController: UIViewController? {
        guard let rootController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        return searchTopController(for: rootController)
    }
    
    func searchTopController(for controller: UIViewController) -> UIViewController {
        if let presentedViewController = controller.presentedViewController {
            return searchTopController(for: presentedViewController)
        } else if let navigationController = controller as? UINavigationController,
                  let lastViewController = navigationController.viewControllers.last {
            return searchTopController(for: lastViewController)
        } else if let tabBarController = controller as? UITabBarController,
                  let selectedController = tabBarController.selectedViewController {
            return searchTopController(for: selectedController)
        } else {
            return controller
        }
    }
}
