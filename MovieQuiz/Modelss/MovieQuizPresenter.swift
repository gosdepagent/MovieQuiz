//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Yanye Velikanova on 12/9/24.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
        weak var viewController: MovieQuizViewController?
        
        func yesButtonClicked() {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = true
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
            return QuizStepViewModel(
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "1/10" // Здесь можно вставить реальную логику
            )
        }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
