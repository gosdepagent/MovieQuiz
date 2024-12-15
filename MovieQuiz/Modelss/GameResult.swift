//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Yanye Velikanova on 11/17/24.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
