import UIKit

extension UIWindow {
    public func topViewController() -> UIViewController? {
        return rootViewController.map(topViewController)
    }

    private func topViewController(with root: UIViewController) -> UIViewController {
        if let selectedController = (root as? UITabBarController)?.selectedViewController {
            return topViewController(with: selectedController)
        } else if let visibleController = (root as? UINavigationController)?.visibleViewController {
            return topViewController(with: visibleController)
        } else {
            return root.presentedViewController.map(topViewController) ?? root
        }
    }
}
