//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Yanye Velikanova on 11/17/24.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }

    func store(correct count: Int, total amount: Int)
}



