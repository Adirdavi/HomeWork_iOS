//
//  EndGameViewController.swift
//  HomeWork_iOS
//
//  Created by Adir Davidov on 12/06/2025.
//

import UIKit
import AudioToolbox

class EndGameViewController: UIViewController {
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var backToMenuButton: UIButton!
    
    private let trophyImageView = UIImageView()
    private let separatorLine = UIView()
    private let gameStatsLabel = UILabel()
    private let decorativeView1 = UIView()
    private let decorativeView2 = UIView()
    
    var winnerName: String = ""
    var playerName: String = "Player"
    var playerScore: Int = 0
    var computerScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameViewController.isActive = false
        
        setupUI()
        playVictorySound()
        
        animateEntrance()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func orientationChanged() {
        DispatchQueue.main.async {
            self.setupCenteredConstraints()
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        guard let winnerLabel = winnerLabel,
              let scoreLabel = scoreLabel,
              let backToMenuButton = backToMenuButton else {
            return
        }
        
        winnerLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        backToMenuButton.translatesAutoresizingMaskIntoConstraints = false
        
        setupWinnerLabel()
        setupScoreLabel()
        setupButton()
        
        setupCenteredConstraints()
    }
    
    private func setupCenteredConstraints() {
        view.removeConstraints(view.constraints)
        
        let isLandscape = UIDevice.current.orientation.isLandscape || view.bounds.width > view.bounds.height
        
        if isLandscape {
            NSLayoutConstraint.activate([
                winnerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                winnerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
                winnerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                winnerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                winnerLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
                winnerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
                
                scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                scoreLabel.topAnchor.constraint(equalTo: winnerLabel.bottomAnchor, constant: 15),
                scoreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
                scoreLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
                scoreLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
                scoreLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
                
                backToMenuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                backToMenuButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
                backToMenuButton.widthAnchor.constraint(equalToConstant: 150),
                backToMenuButton.heightAnchor.constraint(equalToConstant: 35)
            ])
        } else {
            NSLayoutConstraint.activate([
                winnerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                winnerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
                winnerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
                winnerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
                
                scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                scoreLabel.topAnchor.constraint(equalTo: winnerLabel.bottomAnchor, constant: 40),
                scoreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
                scoreLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
                scoreLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
                
                backToMenuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                backToMenuButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 50),
                backToMenuButton.widthAnchor.constraint(equalToConstant: 200),
                backToMenuButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.setupCenteredConstraints()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func setupWinnerLabel() {
        if winnerName == playerName {
            winnerLabel.text = "🏆 Winner: \(winnerName)!"
            winnerLabel.textColor = .systemGreen
        } else if winnerName == "PC" {
            winnerLabel.text = "🤖 Winner: Computer!"
            winnerLabel.textColor = .systemRed
        } else {
            winnerLabel.text = "🤝 It's a Tie!"
            winnerLabel.textColor = .systemOrange
        }
        
        winnerLabel.textAlignment = .center
        winnerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        winnerLabel.numberOfLines = 2
        winnerLabel.adjustsFontSizeToFitWidth = true
        winnerLabel.minimumScaleFactor = 0.3
        winnerLabel.lineBreakMode = .byWordWrapping
        
        winnerLabel.backgroundColor = UIColor.clear
        winnerLabel.isHidden = false
        winnerLabel.alpha = 1.0
        
        winnerLabel.layer.shadowColor = UIColor.black.cgColor
        winnerLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        winnerLabel.layer.shadowOpacity = 0.3
        winnerLabel.layer.shadowRadius = 3
    }
    
    private func setupScoreLabel() {
        let winnerScore = winnerName == playerName ? playerScore :
                         winnerName == "PC" ? computerScore :
                         max(playerScore, computerScore)
        
        scoreLabel.text = "Score: \(winnerScore)"
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        scoreLabel.textColor = .label
        scoreLabel.numberOfLines = 1
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.minimumScaleFactor = 0.5
        
        scoreLabel.sizeToFit()
        
        scoreLabel.backgroundColor = UIColor.clear
        scoreLabel.layer.cornerRadius = 0
        scoreLabel.layer.masksToBounds = false
        scoreLabel.layer.borderWidth = 0
        scoreLabel.layer.borderColor = UIColor.clear.cgColor
        
        scoreLabel.layoutMargins = UIEdgeInsets.zero
    }
    
    private func setupButton() {
        backToMenuButton.setTitle("BACK TO MENU", for: .normal)
        backToMenuButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        backToMenuButton.backgroundColor = .systemBlue
        backToMenuButton.setTitleColor(.white, for: .normal)
        backToMenuButton.layer.cornerRadius = 12
        
        backToMenuButton.layer.shadowColor = UIColor.black.cgColor
        backToMenuButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        backToMenuButton.layer.shadowOpacity = 0.3
        backToMenuButton.layer.shadowRadius = 6
        
        backToMenuButton.addTarget(self, action: #selector(backToMenuTapped), for: .touchUpInside)
    }
    
    private func playVictorySound() {
        AudioServicesPlaySystemSound(1407)
    }
    
    private func animateEntrance() {
        winnerLabel.transform = CGAffineTransform(translationX: 0, y: -100)
        scoreLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        backToMenuButton.transform = CGAffineTransform(translationX: 0, y: 100)
        
        winnerLabel.alpha = 0
        scoreLabel.alpha = 0
        backToMenuButton.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8) {
            self.winnerLabel.transform = CGAffineTransform.identity
            self.winnerLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.scoreLabel.transform = CGAffineTransform.identity
            self.scoreLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 1.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3) {
            self.backToMenuButton.transform = CGAffineTransform.identity
            self.backToMenuButton.alpha = 1
        }
    }
    
    @objc private func backToMenuTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.backToMenuButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.backToMenuButton.transform = CGAffineTransform.identity
            } completion: { _ in
                self.navigateBackToMain()
            }
        }
    }
    
    private func navigateBackToMain() {
        GameViewController.isActive = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            window.rootViewController?.dismiss(animated: true) {
            }
            return
        }
        
        dismiss(animated: true) {
            if let presentingVC = self.presentingViewController as? GameViewController {
                presentingVC.dismiss(animated: true) {
                }
            } else if let presentingVC = self.presentingViewController {
                presentingVC.dismiss(animated: true) {
                }
            }
            
            NotificationCenter.default.post(
                name: NSNotification.Name("ReturnToMainMenu"),
                object: nil
            )
        }
    }
    
    @IBAction func unwindToMainMenu(_ segue: UIStoryboardSegue) {
        GameViewController.isActive = false
    }
}

extension EndGameViewController {
    
    func setGameResults(winner: String, playerName: String, playerScore: Int, computerScore: Int) {
        self.winnerName = winner
        self.playerName = playerName
        self.playerScore = playerScore
        self.computerScore = computerScore
    }
}
