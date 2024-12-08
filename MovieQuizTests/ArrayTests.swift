//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Yanye Velikanova on 12/7/24.
//

import Foundation
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // given
        let array = [1,1,2,3,4]
        
        // when
        let value = array[safe:2]
        
        //then
        XCTAssertNotNil(value)
        XCTAssertEqual(value,2)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1,1,2,3,4]
        let value = array[safe: 20]
        XCTAssertNil(value)
        
    }
}
