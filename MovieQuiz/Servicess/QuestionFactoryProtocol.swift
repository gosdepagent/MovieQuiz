//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Yanye Velikanova on 11/11/24.
//

import Foundation

protocol QuestionFactoryProtocol {
    func loadData()
    func requestNextQuestion()
    func setup(delegate: QuestionFactoryDelegate)
}

 
   
   
