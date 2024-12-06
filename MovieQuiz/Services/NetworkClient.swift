//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Yanye Velikanova on 12/3/24.
//

import Foundation

/// Отвечает за загрузку данных по URL

struct NetworkClient {
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        print("Запрос к URL: \(url)")
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                print("Ошибка при запросе: \(error.localizedDescription)")
                handler(.failure(error))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("Неверный код ответа: \(response.statusCode)")
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // Возвращаем данные
            guard let data = data else {
                print("Данные отсутствуют")
                return
            }
            handler(.success(data))
        }
        
        task.resume()
    }
}
