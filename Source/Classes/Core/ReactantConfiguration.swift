//
//  ProjectBaseConfiguration.swift
//  Pods
//
//  Created by Tadeáš Kříž on 12/06/16.
//
//

#if os(iOS)
    import UIKit
#endif


public struct ReactantConfiguration {
    public static var global = ReactantConfiguration()

    #if os(iOS)
    public var layoutMargins = UIEdgeInsets.zero
    #endif


    public var controllerRootStyle: (ControllerRootViewContainer) -> Void = { _ in }
    public var emptyListLabelStyle: (Label) -> Void = { _ in }
    public var defaultLoadingMessage = "Loading .."
    public var closeButtonTitle = "Close"
    public var defaultBackButtonTitle: String? = nil
    public var dialogStyle: (View) -> Void = { _ in }
    public var dialogContentContainerStyle: (View) -> Void = { _ in }

    #if os(iOS)
    public var loadingIndicatorStyle: UIActivityIndicatorViewStyle = .gray
    #elseif os(macOS)
    public var loadingIndicatorStyle: NSProgressIndicatorStyle = .spinningStyle
    #endif
}
