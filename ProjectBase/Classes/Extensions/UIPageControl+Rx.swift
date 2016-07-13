//
//  UIPageControl+Rx.swift
//  Rx
//
//  Created by Francesco Puntillo on 14/04/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension UIPageControl {

    /**
     Bindable sink for `currentPage` property.
     */
    public var rx_currentPage: AnyObserver<Int> {
        return UIBindingObserver(UIElement: self) { controller, page in
            controller.currentPage = page
            }.asObserver()
    }
}