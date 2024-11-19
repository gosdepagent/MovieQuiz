//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Yanye Velikanova on 11/15/24.
//

import Foundation
import UIKit

class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func presentAlert(with model: AlertModel) {
        delegate?.showAlert(with: model)
    }
}
