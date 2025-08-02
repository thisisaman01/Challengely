//
//  ShareCardViewRenderer.swift
//  Challengely
//
//  Created by AMAN K.A on 01/08/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import UIKit

struct ShareCardViewRenderer {
    static func render<V: View>(view: V) -> UIImage {
        let controller = UIHostingController(rootView: view)
        let view = controller.view
        let targetSize = CGSize(width: 340, height: 500)
        let window = UIWindow(frame: CGRect(origin: .zero, size: targetSize))
        window.rootViewController = controller
        window.layoutIfNeeded()
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        view?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }
}
