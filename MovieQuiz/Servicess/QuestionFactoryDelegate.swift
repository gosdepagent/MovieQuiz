//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Yanye Velikanova on 11/11/24.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {              
    func didReceiveNextQuestion(question: QuizQuestion?)    
  
}

