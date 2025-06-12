//
//  GameViewController.swift
//  HomeWork_iOS
//
//  Created by Adir Davidov on 11/06/2025.
//

import UIKit
import AVFoundation
import AudioToolbox

class GameViewController: UIViewController {
    
    static var isActive = false
    
    var playerName: String = "Player"
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var cardSoundPlayer: AVAudioPlayer?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        if GameViewController.isActive {
            super.init(nibName: nil, bundle: nil)
            return
        }
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        if GameViewController.isActive {
            return nil
        }
        
        super.init(coder: coder)
    }
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var computerNameLabel: UILabel!
    @IBOutlet weak var computerScoreLabel: UILabel!
    @IBOutlet weak var playerCardImageView: UIImageView!
    @IBOutlet weak var computerCardImageView: UIImageView!
    @IBOutlet weak var timerImageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    
    var playerScore = 0
    var computerScore = 0
    var timer: Timer?
    var gameTimer: Timer?
    var showingCards = false
    var roundCounter = 0
    var maxRounds = 2
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    let timerImages = [
        "eight", "five", "four", "nine", "seven",
        "six", "ace", "ten", "three", "two"
    ]
    
    static func canCreateNewInstance() -> Bool {
        return !GameViewController.isActive
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameViewController.isActive = true
        
        setupAudio()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(returnToMainMenu),
            name: NSNotification.Name("ReturnToMainMenu"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateImagesForCurrentMode),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        setupUI()
        setupInitialConstraints()
        
        startBackgroundMusic()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startGameCycle()
        }
    }
    
    @objc private func returnToMainMenu() {
        stopAllTimers()
        stopBackgroundMusic()
        GameViewController.isActive = false
        
        dismiss(animated: true) {
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: NSNotification.Name("StopAllOtherTimers"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopAllTimers()
        stopBackgroundMusic()
        
        GameViewController.isActive = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopAllTimers()
        stopBackgroundMusic()
        GameViewController.isActive = false
    }
    
    deinit {
        stopAllTimers()
        stopBackgroundMusic()
        GameViewController.isActive = false
        
        NotificationCenter.default.removeObserver(self)
    }

    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        }
        
        setupBackgroundMusic()
        setupCardSound()
    }
    
    private func setupBackgroundMusic() {
        let possibleFiles = [
            ("background_music", "mp3"),
            ("background_music", ""),
            ("background_music", "wav"),
            ("background_music", "m4a"),
            ("game_music", "mp3"),
            ("music", "mp3")
        ]
        
        for (name, ext) in possibleFiles {
            let url: URL?
            if ext == "" {
                url = Bundle.main.url(forResource: name, withExtension: nil)
            } else {
                url = Bundle.main.url(forResource: name, withExtension: ext)
            }
            
            if let audioUrl = url {
                do {
                    backgroundMusicPlayer = try AVAudioPlayer(contentsOf: audioUrl)
                    backgroundMusicPlayer?.numberOfLoops = -1
                    backgroundMusicPlayer?.volume = 0.8
                    
                    if backgroundMusicPlayer?.prepareToPlay() == true {
                        return
                    }
                    
                } catch {
                }
            }
        }
    }
    
    private func setupCardSound() {
        let possibleFiles = [
            ("card_flip", "mp3"),
            ("card_flip", ""),
            ("card_flip", "wav"),
            ("card_sound", "mp3"),
            ("flip", "mp3")
        ]
        
        for (name, ext) in possibleFiles {
            let url: URL?
            if ext == "" {
                url = Bundle.main.url(forResource: name, withExtension: nil)
            } else {
                url = Bundle.main.url(forResource: name, withExtension: ext)
            }
            
            if let audioUrl = url {
                do {
                    cardSoundPlayer = try AVAudioPlayer(contentsOf: audioUrl)
                    cardSoundPlayer?.volume = 0.9
                    cardSoundPlayer?.prepareToPlay()
                    return
                } catch {
                }
            }
        }
    }
    
    private func startBackgroundMusic() {
        guard let player = backgroundMusicPlayer else {
            return
        }
        
        player.play()
    }
    
    private func stopBackgroundMusic() {
        guard let player = backgroundMusicPlayer else { return }
        
        if player.isPlaying {
            player.stop()
            player.currentTime = 0
        }
    }
    
    private func playCardSound() {
        guard let player = cardSoundPlayer else {
            AudioServicesPlaySystemSound(1306)
            return
        }
        
        player.stop()
        player.currentTime = 0
        
        if !player.play() {
            AudioServicesPlaySystemSound(1306)
        }
    }
    
    @objc private func updateImagesForCurrentMode() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        if isDarkMode {
            timerImageView.image = UIImage(named: "stopwatch_night")
        } else {
            timerImageView.image = UIImage(named: "stopwatch")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateImagesForCurrentMode()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            let isLandscape = size.width > size.height
            
            NSLayoutConstraint.deactivate(self.portraitConstraints)
            NSLayoutConstraint.deactivate(self.landscapeConstraints)
            
            if isLandscape {
                NSLayoutConstraint.activate(self.landscapeConstraints)
            } else {
                self.resetToPortraitMode()
            }
            
            self.view.layoutIfNeeded()
            
        }, completion: { _ in
            DispatchQueue.main.async {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        })
    }
    
    private func resetToPortraitMode() {
        let currentPlayerScore = playerScoreLabel.text ?? "0"
        let currentComputerScore = computerScoreLabel.text ?? "0"
        let currentTimerValue = timerLabel.text ?? "4"
        let currentPlayerImage = playerCardImageView.image
        let currentComputerImage = computerCardImageView.image
        
        resetAllTransforms()
        
        NSLayoutConstraint.activate(portraitConstraints)
        
        playerNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        computerNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        playerScoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        computerScoreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        timerLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        playerScoreLabel.text = currentPlayerScore
        computerScoreLabel.text = currentComputerScore
        timerLabel.text = currentTimerValue
        playerCardImageView.image = currentPlayerImage
        computerCardImageView.image = currentComputerImage
    }
    
    private func resetAllTransforms() {
        playerNameLabel.transform = CGAffineTransform.identity
        computerNameLabel.transform = CGAffineTransform.identity
        playerScoreLabel.transform = CGAffineTransform.identity
        computerScoreLabel.transform = CGAffineTransform.identity
        timerImageView.transform = CGAffineTransform.identity
        timerLabel.transform = CGAffineTransform.identity
        playerCardImageView.transform = CGAffineTransform.identity
        computerCardImageView.transform = CGAffineTransform.identity
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        guard let playerNameLabel = playerNameLabel,
              let playerScoreLabel = playerScoreLabel,
              let computerNameLabel = computerNameLabel,
              let computerScoreLabel = computerScoreLabel,
              let playerCardImageView = playerCardImageView,
              let computerCardImageView = computerCardImageView,
              let timerImageView = timerImageView,
              let timerLabel = timerLabel else {
            return
        }
        
        playerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        playerScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        computerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        computerScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        playerCardImageView.translatesAutoresizingMaskIntoConstraints = false
        computerCardImageView.translatesAutoresizingMaskIntoConstraints = false
        timerImageView.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setupLabel(playerNameLabel, text: playerName, fontSize: 18, weight: .bold)
        setupLabel(playerScoreLabel, text: "0", fontSize: 24, weight: .bold)
        setupLabel(computerNameLabel, text: "PC", fontSize: 18, weight: .bold)
        setupLabel(computerScoreLabel, text: "0", fontSize: 24, weight: .bold)
        setupLabel(timerLabel, text: "4", fontSize: 24, weight: .bold)
        
        setupCardImageView(playerCardImageView)
        setupCardImageView(computerCardImageView)
        
        timerLabel.textColor = .systemGreen
        timerImageView.contentMode = .scaleAspectFit
        updateImagesForCurrentMode()
        
        setCardsToBack()
    }
    
    private func setupLabel(_ label: UILabel, text: String, fontSize: CGFloat = 16, weight: UIFont.Weight = .medium) {
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCardImageView(_ imageView: UIImageView) {
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupInitialConstraints() {
        view.removeConstraints(view.constraints)
        
        portraitConstraints = [
            playerNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            playerNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            
            playerScoreLabel.topAnchor.constraint(equalTo: playerNameLabel.bottomAnchor, constant: 5),
            playerScoreLabel.centerXAnchor.constraint(equalTo: playerNameLabel.centerXAnchor),
            
            computerNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            computerNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            computerScoreLabel.topAnchor.constraint(equalTo: computerNameLabel.bottomAnchor, constant: 5),
            computerScoreLabel.centerXAnchor.constraint(equalTo: computerNameLabel.centerXAnchor),
            
            timerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerImageView.topAnchor.constraint(equalTo: playerScoreLabel.bottomAnchor, constant: 50),
            timerImageView.widthAnchor.constraint(equalToConstant: 80),
            timerImageView.heightAnchor.constraint(equalToConstant: 80),
            
            timerLabel.centerXAnchor.constraint(equalTo: timerImageView.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: timerImageView.bottomAnchor, constant: 5),
            
            playerCardImageView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 30),
            playerCardImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            playerCardImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.37),
            playerCardImageView.heightAnchor.constraint(equalTo: playerCardImageView.widthAnchor, multiplier: 1.5),
            
            computerCardImageView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 30),
            computerCardImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            computerCardImageView.widthAnchor.constraint(equalTo: playerCardImageView.widthAnchor),
            computerCardImageView.heightAnchor.constraint(equalTo: playerCardImageView.heightAnchor)
        ]
        
        landscapeConstraints = [
            playerNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            playerNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 55),
            
            playerScoreLabel.topAnchor.constraint(equalTo: playerNameLabel.bottomAnchor, constant: 5),
            playerScoreLabel.centerXAnchor.constraint(equalTo: playerNameLabel.centerXAnchor),
            
            computerNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            computerNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -55),
            
            computerScoreLabel.topAnchor.constraint(equalTo: computerNameLabel.bottomAnchor, constant: 5),
            computerScoreLabel.centerXAnchor.constraint(equalTo: computerNameLabel.centerXAnchor),
            
            timerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerImageView.topAnchor.constraint(equalTo: playerScoreLabel.bottomAnchor, constant: 20),
            timerImageView.widthAnchor.constraint(equalToConstant: 60),
            timerImageView.heightAnchor.constraint(equalToConstant: 60),
            
            timerLabel.centerXAnchor.constraint(equalTo: timerImageView.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: timerImageView.bottomAnchor, constant: 3),
            
            playerCardImageView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: -65),
            playerCardImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 90),
            playerCardImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            playerCardImageView.heightAnchor.constraint(equalTo: playerCardImageView.widthAnchor, multiplier: 1.5),
            
            computerCardImageView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: -65),
            computerCardImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -90),
            computerCardImageView.widthAnchor.constraint(equalTo: playerCardImageView.widthAnchor),
            computerCardImageView.heightAnchor.constraint(equalTo: playerCardImageView.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(portraitConstraints)
    }
    
    private func startGameCycle() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showNewCards()
        }
    }
    
    private func stopAllTimers() {
        timer?.invalidate()
        timer = nil
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func showNewCards() {
        if roundCounter >= maxRounds {
            endGame()
            return
        }
        
        roundCounter += 1
        
        showingCards = true
        dealNewCards()
        startTimer(duration: 4)
    }
    
    private func startTimer(duration: Int) {
        var timeLeft = duration
        
        timerLabel.text = "\(timeLeft)"
        timerLabel.textColor = .systemGreen
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] currentTimer in
            guard let self = self else {
                currentTimer.invalidate()
                return
            }
            
            timeLeft -= 1
            
            DispatchQueue.main.async {
                self.timerLabel.text = "\(timeLeft)"
                
                if timeLeft <= 1 {
                    self.timerLabel.textColor = .systemRed
                } else {
                    self.timerLabel.textColor = .systemGreen
                }
            }
            
            if timeLeft == 2 && self.showingCards {
                self.showingCards = false
                DispatchQueue.main.async {
                    self.setCardsToBack()
                }
            }
            
            if timeLeft <= 0 {
                currentTimer.invalidate()
                self.timer = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.showNewCards()
                }
            }
        }
    }
    
    private func setCardsToBack() {
        UIView.transition(with: playerCardImageView, duration: 0.4, options: .transitionFlipFromLeft) {
            self.playerCardImageView.image = UIImage(named: "backcard")
        }
        
        UIView.transition(with: computerCardImageView, duration: 0.4, options: .transitionFlipFromRight) {
            self.computerCardImageView.image = UIImage(named: "backcard")
        }
    }
    
    private func dealNewCards() {
        let playerCardName = timerImages.randomElement() ?? "ace"
        let computerCardName = timerImages.randomElement() ?? "ace"
        
        playCardSound()
        
        UIView.transition(with: playerCardImageView, duration: 0.4, options: .transitionFlipFromRight) {
            self.playerCardImageView.image = UIImage(named: playerCardName)
        }
        
        UIView.transition(with: computerCardImageView, duration: 0.4, options: .transitionFlipFromLeft) {
            self.computerCardImageView.image = UIImage(named: computerCardName)
        }
        
        let playerValue = getCardValue(cardName: playerCardName)
        let computerValue = getCardValue(cardName: computerCardName)
        
        if playerValue > computerValue {
            playerScore += 1
        } else if computerValue > playerValue {
            computerScore += 1
        }
        
        playerScoreLabel.text = "\(playerScore)"
        computerScoreLabel.text = "\(computerScore)"
        
        UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0) {
            self.playerScoreLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            self.computerScoreLabel.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.playerScoreLabel.transform = CGAffineTransform.identity
                self.computerScoreLabel.transform = CGAffineTransform.identity
            }
        }
    }
    
    private func getCardValue(cardName: String) -> Int {
        switch cardName {
        case "two": return 2
        case "three": return 3
        case "four": return 4
        case "five": return 5
        case "six": return 6
        case "seven": return 7
        case "eight": return 8
        case "nine": return 9
        case "ten": return 10
        case "ace": return 11
        default: return 0
        }
    }
    
    private func endGame() {
        stopAllTimers()
        stopBackgroundMusic()
        
        let winner = playerScore > computerScore ? playerName :
                    computerScore > playerScore ? "PC" : "תיקו"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigateToEndGame(winner: winner)
        }
    }
    
    private func navigateToEndGame(winner: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let endGameVC = storyboard.instantiateViewController(withIdentifier: "EndGameViewController") as? EndGameViewController {
            endGameVC.setGameResults(
                winner: winner,
                playerName: playerName,
                playerScore: playerScore,
                computerScore: computerScore
            )
            
            endGameVC.modalPresentationStyle = .fullScreen
            endGameVC.modalTransitionStyle = .crossDissolve
            
            present(endGameVC, animated: true) {
                GameViewController.isActive = false
            }
        } else {
           return
        }
    }
    
    private func backToMainMenu() {
        GameViewController.isActive = false
        
        let gameData: [String: Any] = [
            "winner": playerScore > computerScore ? playerName : computerScore > playerScore ? "PC" : "TIE",
            "playerName": playerName,
            "playerScore": playerScore,
            "computerScore": computerScore
        ]
        
        NotificationCenter.default.post(
            name: NSNotification.Name("GameFinished"),
            object: nil,
            userInfo: gameData
        )
        
        dismiss(animated: true) {
        }
    }
    
    private func resetGame() {
        playerScore = 0
        computerScore = 0
        roundCounter = 0
        showingCards = false
        
        stopAllTimers()
        
        playerScoreLabel.text = "0"
        computerScoreLabel.text = "0"
        timerLabel.text = "4"
        timerLabel.textColor = .systemGreen
        setCardsToBack()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startGameCycle()
        }
    }
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        playCardSound()
        
        guard let tappedView = gesture.view else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            tappedView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                tappedView.transform = CGAffineTransform.identity
            }
        }
    }
}
