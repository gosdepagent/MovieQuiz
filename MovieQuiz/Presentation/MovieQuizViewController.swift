import UIKit

final class MovieQuizViewController: UIViewController {
   
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBOutlet private var textLabel: UILabel!
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
    
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var counterLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
            yesButton.layer.cornerRadius = 20
            yesButton.layer.masksToBounds = true
            
            noButton.layer.cornerRadius = 20
            noButton.layer.masksToBounds = true
            
         
            func show(quiz step: QuizStepViewModel) {
                imageView.image = step.image
                textLabel.text = step.question
                counterLabel.text = step.questionNumber

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.showNextQuestionOrResults()
                }
            }
        }
    
    
  
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    
    struct QuizQuestion {
       
        let image: String
    
        let text: String
      
        let correctAnswer: Bool
    }
    
    
    
    
    
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
        QuizQuestion(image: "The Dark Knight",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
        QuizQuestion(image: "Kill Bill",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
        QuizQuestion(image: "The Avengers",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
        QuizQuestion(image: "Deadpool",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
        QuizQuestion(image: "The Green Knight",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: true),
        QuizQuestion(image: "Old",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: false),
        QuizQuestion(image: "Tesla",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: false),
        QuizQuestion(image: "Vivarium",text: "Рейтинг этого фильма больше чем 6?",correctAnswer: false)
    ]
    
    struct QuizStepViewModel {
        
        let image: UIImage
       
        let question: String
  
        let questionNumber: String
    }
    
    
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text, // 3
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    
    
    
    
  
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            
            let text = "Ваш результат: \(correctAnswers)/10"
            let resultViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: resultViewModel)
        } else {
           
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            showQuizStep(viewModel)
        }
    }
    
   
    private func showQuizStep(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
           
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.showQuizStep(viewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
