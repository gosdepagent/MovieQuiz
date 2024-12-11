
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate  {
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var statisticService: StatisticServiceProtocol!
   //  private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
   //  var currentQuestionIndex = 0
    var correctAnswers = 0
    var alertPresenter: AlertPresenter?
    var isAnswered = false
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        
        print("Initializing MovieQuizViewController...")
        statisticService = StatisticService()
        alertPresenter = AlertPresenter(delegate: self)
        
        setupUI()
        print("Showing loading indicator...")
        
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        print("Request Next question")
        questionFactory?.requestNextQuestion()
    }

     func setupUI() {
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
        yesButton.layer.cornerRadius = 20
        yesButton.layer.masksToBounds = true
        
        noButton.layer.cornerRadius = 20
        noButton.layer.masksToBounds = true
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    @IBAction func yesButtonClicked(_ sender: UIButton) {
       presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }

    private func showLoadingIndicator() {
        print("Показать индикатор загрузки.")
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        print("Скрыть индикатор загрузки.")
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    func didLoadDataFromServer() {
        print("Данные успешно загружены с сервера.")
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        print("Ошибка при загрузке данных с сервера: \(error.localizedDescription)")
        showNetworkError(message: error.localizedDescription)
    }

    func showAlert(with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        if let completion = model.completion {
            let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
                completion() // Выполнение замыкания
            }
            alert.addAction(action)
        } else {
            let action = UIAlertAction(title: model.buttonText, style: .default, handler: nil)
            alert.addAction(action)
        }
        
        present(alert, animated: true, completion: nil)
    }

    private func showQuizStep(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
        
        isAnswered = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            if self.imageView.layer.borderColor == UIColor.clear.cgColor && self.isAnswered {
                self.showNextQuestionOrResults()
            }
        }
    }

     func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        isAnswered = true
        
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let totalGames = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let averageAccuracy = statisticService.totalAccuracy
            
            let resultMessage = "\nКоличество сыгранных игр: \(totalGames)\n\u{1F3C6} Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date))\nСредняя точность: \(String(format: "%.2f", averageAccuracy))%"


            let resultViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultMessage,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: resultViewModel)
        } else {
            presenter.switchToNextQuestion()
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
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuizStep(viewModel)
        }
    }

    private func showNetworkError(message: String) {
        print("Ошибка сети")
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.presentAlert(with: model)
    }
}
