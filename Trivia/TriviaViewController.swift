//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

class TriviaViewController: UIViewController {
    
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var answerButton0: UIButton!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!

    private var questions = [TriviaQuestion]()
    private var currQuestionIndex = 0
    private var numCorrectQuestions = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        questionContainerView.layer.cornerRadius = 8.0
        fetchQuestions()
    }

    // MARK: - Fetch from API
    private func fetchQuestions() {
        let service = TriviaQuestionService()
        service.fetchTriviaQuestions { [weak self] questions in
            DispatchQueue.main.async {
                self?.questions = questions
                self?.currQuestionIndex = 0
                self?.numCorrectQuestions = 0
                if !questions.isEmpty {
                    self?.updateQuestion(withQuestionIndex: 0)
                }
            }
        }
    }

    // MARK: - UI Update
    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
        let question = questions[questionIndex]
        questionLabel.text = htmlDecode(question.question)
        categoryLabel.text = question.category

        let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()

        let buttons = [answerButton0, answerButton1, answerButton2, answerButton3]

        for (i, button) in buttons.enumerated() {
            if i < answers.count {
                button?.setTitle(htmlDecode(answers[i]), for: .normal)
                button?.isHidden = false
            } else {
                button?.isHidden = true
            }
        }
    }

    // MARK: - Answer Handling
    private func updateToNextQuestion(answer: String) {
        let correct = isCorrectAnswer(answer)
        if correct {
            numCorrectQuestions += 1
        }

        let alert = UIAlertController(
            title: correct ? "Correct!" : "Wrong!",
            message: "The correct answer was: \(questions[currQuestionIndex].correctAnswer)",
            preferredStyle: .alert
        )

        let nextAction = UIAlertAction(title: "Next", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currQuestionIndex += 1
            if self.currQuestionIndex < self.questions.count {
                self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
            } else {
                self.showFinalScore()
            }
        }

        alert.addAction(nextAction)
        present(alert, animated: true)
    }

    private func isCorrectAnswer(_ answer: String) -> Bool {
        return answer == questions[currQuestionIndex].correctAnswer
    }

    // MARK: - Final Score
    private func showFinalScore() {
        let alertController = UIAlertController(
            title: "Game Over!",
            message: "Final score: \(numCorrectQuestions)/\(questions.count)",
            preferredStyle: .alert
        )

        let resetAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.fetchQuestions()
        }

        alertController.addAction(resetAction)
        present(alertController, animated: true)
    }

    // MARK: - Gradient Background
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Button Actions
    @IBAction func didTapAnswerButton0(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }

    @IBAction func didTapAnswerButton1(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }

    @IBAction func didTapAnswerButton2(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }

    @IBAction func didTapAnswerButton3(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }

    // MARK: - HTML Decoding Helper
    private func htmlDecode(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html
        ]
        let decoded = try? NSAttributedString(data: data, options: options, documentAttributes: nil).string
        return decoded ?? string
    }
}
