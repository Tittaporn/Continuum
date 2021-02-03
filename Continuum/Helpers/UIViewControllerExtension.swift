//
//  UIViewControllerExtension.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import Foundation


import UIKit

extension UIViewController {
    func presentErrorToUser(textAlert: String) {
        let alertController = UIAlertController(title: "ERROR", message: textAlert, preferredStyle: .actionSheet)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}
