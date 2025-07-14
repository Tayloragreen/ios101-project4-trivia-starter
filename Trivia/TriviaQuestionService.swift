//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Taylor Green on 7/14/25.
//


import Foundation

class TriviaQuestionService {
    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]) -> Void) {
        let group = DispatchGroup()
        var allQuestions: [TriviaQuestion] = []
        
        // Fetch multiple choice
        group.enter()
        fetchQuestions(from: "https://opentdb.com/api.php?amount=3&type=multiple") { result in
            allQuestions += result
            group.leave()
        }

        // Fetch true/false
        group.enter()
        fetchQuestions(from: "https://opentdb.com/api.php?amount=2&type=boolean") { result in
            allQuestions += result
            group.leave()
        }

        // Return all questions once both are done
        group.notify(queue: .main) {
            completion(allQuestions.shuffled())
        }
    }

    private func fetchQuestions(from urlString: String, completion: @escaping ([TriviaQuestion]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("Failed to fetch: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
                completion(decoded.results)
            } catch {
                print("Failed to decode: \(error)")
                completion([])
            }
        }.resume()
    }
}

struct TriviaResponse: Decodable {
    let results: [TriviaQuestion]
}

