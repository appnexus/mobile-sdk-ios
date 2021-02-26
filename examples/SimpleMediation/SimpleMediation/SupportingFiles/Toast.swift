/*   Copyright 2020 APPNEXUS INC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/




import UIKit
import Foundation

class Toast {
    static func show(message: String, controller: UIViewController) {
        let toastView = UIView(frame: CGRect())
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastView.alpha = 0.0
        toastView.layer.cornerRadius = 25;
        toastView.clipsToBounds  =  true

        let toastTitle = UILabel(frame: CGRect())
        toastTitle.textColor = UIColor.white
        toastTitle.textAlignment = .center;
        toastTitle.font.withSize(12.0)
        toastTitle.text = message
        toastTitle.clipsToBounds  =  true
        toastTitle.numberOfLines = 0

        toastView.addSubview(toastTitle)
        controller.view.addSubview(toastView)

        toastTitle.translatesAutoresizingMaskIntoConstraints = false
        toastView.translatesAutoresizingMaskIntoConstraints = false

        let a1 = NSLayoutConstraint(item: toastTitle, attribute: .leading, relatedBy: .equal, toItem: toastView, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastTitle, attribute: .trailing, relatedBy: .equal, toItem: toastView, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastTitle, attribute: .bottom, relatedBy: .equal, toItem: toastView, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastTitle, attribute: .top, relatedBy: .equal, toItem: toastView, attribute: .top, multiplier: 1, constant: 15)
        toastView.addConstraints([a1, a2, a3, a4])

        let c1 = NSLayoutConstraint(item: toastView, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
        let c2 = NSLayoutConstraint(item: toastView, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
        let c3 = NSLayoutConstraint(item: toastView, attribute: .bottom, relatedBy: .equal, toItem: controller.view, attribute: .bottom, multiplier: 1, constant: -75)
        controller.view.addConstraints([c1, c2, c3])

        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastView.alpha = 0.0
            }, completion: {_ in
                toastView.removeFromSuperview()
            })
        })
    }
}
