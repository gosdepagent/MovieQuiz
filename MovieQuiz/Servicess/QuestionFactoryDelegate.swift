//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Yanye Velikanova on 11/11/24.
//

import Foundation

protocol QuestionFactoryDelegate {
    func didRecieveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
