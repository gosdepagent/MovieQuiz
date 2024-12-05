
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate  {
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBOutlet private var textLabel: UILabel!
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // скрываем индикатор
        activityIndicator.stopAnimating() // останавливаем анимацию
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private var statisticService: StatisticServiceProtocol!
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    var currentQuestionIndex = 0
    var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statisticService = StatisticService()
        
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        
        
        let questionFactory = QuestionFactory(moviesLoader: <#MoviesLoading#>, delegate: <#QuestionFactoryDelegate?#>)
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
        yesButton.layer.cornerRadius = 20
        yesButton.layer.masksToBounds = true
        
        noButton.layer.cornerRadius = 20
        noButton.layer.masksToBounds = true
        
        questionFactory.requestNextQuestion()
        
    }
    
    private func showQuizStep(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
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
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let totalGames = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let averageAccuracy = statisticService.totalAccuracy
            
            let resultMessage = "\nКоличество сыгранных игр: \(totalGames)\n🏆 Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date))\nСредняя точность: \(String(format: "%.2f", averageAccuracy))%"
            
            let resultViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultMessage,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: resultViewModel)
        } else {
            
            yesButton.isEnabled = true
            noButton.isEnabled = true
            
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuizStep(viewModel)
        }
    }
}
