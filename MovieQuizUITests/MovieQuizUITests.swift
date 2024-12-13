//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Yanye Velikanova on 12/8/24.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    func testNoButton() {
        // Убедитесь, что изображение Poster доступно
        XCTAssertTrue(app.images["Poster"].waitForExistence(timeout: 5), "Poster image did not appear")

        // Убедитесь, что кнопка No существует
        XCTAssertTrue(app.buttons["No"].waitForExistence(timeout: 5), "No button did not appear")
        app.buttons["No"].tap()

        // Убедитесь, что после нажатия кнопки появился новый постер
        XCTAssertTrue(app.images["Poster"].waitForExistence(timeout: 5), "Poster image did not appear after tap")

        // Убедитесь, что элемент Index существует
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Index label does not exist")
        XCTAssertEqual(indexLabel.label, "2/10", "Index label is not updated correctly")
    }

    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        sleep(2)
        
        // Имитируем ответы на вопросы
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts.element(boundBy: 0)

        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Game results alert not found")
        
        let alertTitle = alert.staticTexts.element(boundBy: 0).label
        XCTAssertTrue(alertTitle == "Этот раунд окончен!", "Alert title is incorrect")
        
        let buttonText = alert.buttons.firstMatch.label
        XCTAssertTrue(buttonText == "Сыграть ещё раз", "Retry button text is incorrect")
    }


    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        // Ищем алерт с текстом, который точно появляется
        let alert = app.alerts.element(boundBy: 0)
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Game results alert not found")
        
        // Нажимаем на кнопку "Сыграть ещё раз"
        let retryButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(retryButton.exists, "Retry button not found")
        retryButton.tap()
        
        sleep(2)
        
        // Проверяем, что алерт был закрыт
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Index label does not exist after dismissing alert")
        XCTAssertTrue(indexLabel.label == "1/10", "Index label is not updated correctly after restarting game")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
