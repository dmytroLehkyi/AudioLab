//
//  UIViewController+Extensions.swift
//  AudioLab
//
//  Created by Dmytro Lehkyi on 2/9/20.
//  Copyright © 2020 Dmytro Lehkyi. All rights reserved.
//

import UIKit

extension UIViewController {
    static func loadFromStoryboard() -> Self {
        let viewControllerName = String(describing: Self.self)
        let storyboard = UIStoryboard(name: viewControllerName, bundle: nil)

        guard let controller = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Unable to create \(viewControllerName)")
        }

        return controller
    }
}
