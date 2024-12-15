//
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
      
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
    }
    
    private let storage: UserDefaults = .standard
    
    private var correctAnswers: Int {
        get {
            return storage.integer(forKey: "correctAnswers")
        }
        set {
            storage.set(newValue, forKey: "correctAnswers")
        }
    }

    var totalAccuracy: Double {
        let totalQuestions = gamesCount * 10
        guard totalQuestions > 0 else { return 0.0 }
        return (Double(correctAnswers) / Double(totalQuestions)) * 100
    }

    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult{
    get {
        if let savedData = storage.object(forKey: "Data") as? [String: Any],
           let correct = savedData["correct"] as? Int,
        let total = savedData["total"] as? Int,
           let date = savedData["date"] as? Date {
            return GameResult(correct: correct, total: total, date: date)
        } else {
            return GameResult(correct: 0, total: 0, date: Date()) }
        }
        set {
            let dataToSave: [String:Any] = [
                "correct": newValue.correct,
                        "total": newValue.total,
                        "date": newValue.date
                    ]
    
            storage.set(dataToSave, forKey: "Data")
        }
    }
    
    func store(correct count: Int, total amount: Int) {
       
        correctAnswers += count
        gamesCount += 1
        
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
    }
}

