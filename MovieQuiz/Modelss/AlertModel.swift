//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Yanye Velikanova on 11/15/24.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: (() -> Void)?
}
