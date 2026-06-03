//
//  ViewController.swift
//  TempestTeaApp
//
//  Created by Victoria Alaniz on 4/15/26.
//

import AlarmKit
import UIKit
import SwiftUI

class ViewController: UIViewController {
    typealias AlarmConfiguration = AlarmManager.AlarmConfiguration<TeaCategory>

    // Interface Elements
    let label = UILabel()
    let segmentedControl = UISegmentedControl(items: TeaCategory.allCases.map { $0.name })
    var button = UIButton()

    // Properties
    var futureDate: Date?
    var timeInterval: Double = 0
    var timer: Timer?

    //AlarmKit
    private let alarmManager = AlarmManager.shared
    private var alarmID: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupUI()
        addTargets()
        resetState()
        Task { _ = await requestAuthorization() }
    }

    private func addTargets() {
        segmentedControl.addTarget(self, action: #selector(updateTimeInterval), for: .valueChanged)
        button.addTarget(self, action: #selector(toggleTimer), for: .touchUpInside)
    }

    private func setupUI() {
        // Setup Views
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .button
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.background], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.button], for: .normal)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .extraLargeTitle2)
        label.textColor = .button
        label.translatesAutoresizingMaskIntoConstraints = false

        button.cornerConfiguration = .capsule()
        button.backgroundColor = .button
        button.setTitleColor(.background, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        // Add Subviews
        view.addSubview(label)
        view.addSubview(segmentedControl)
        view.addSubview(button)

        // Constrain View
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 200),
            label.heightAnchor.constraint(equalToConstant: 100),

            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 100),
        ])

    }


    // MARK: - Actions

    @objc private func toggleTimer() {
        guard timer == nil else {
            resetState()
            return
        }

        futureDate = Date(timeIntervalSinceNow: timeInterval)
        button.setTitle("Stop", for: .normal)
        setupAlarm()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(checkTime),
            userInfo: nil,
            repeats: true)
        timer?.fire()
    }

    @objc private func checkTime() {
        guard let futureSeconds = futureDate?.timeIntervalSinceReferenceDate else { return }
        let currentSeconds = Date.now.timeIntervalSinceReferenceDate
        let remainingSeconds = futureSeconds - currentSeconds

        guard remainingSeconds > 0 else {
            timerExpired()
            return
        }

        updateLabel(with: remainingSeconds)
    }

    @objc private func updateTimeInterval() {
        guard let tea = TeaCategory(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        timeInterval = tea.time
        updateLabel(with: timeInterval)
    }

    // MARK: - Utility Methods

    // See if I can get away with only resetState or timerExpired instead of both. If only resetState() is present the timer doesn't trigger
    private func timerExpired() {
        timer?.invalidate()
        timer = nil
        button.setTitle("Start", for: .normal)
        updateTimeInterval()
    }

    private func resetState() {
        stopAlarm()
        timer?.invalidate()
        timer = nil
        button.setTitle("Start", for: .normal)
        updateTimeInterval()
    }

    private func updateLabel(with seconds: Double) {
        let minutesRemaining = Int(seconds / 60)
        let secondsRemaining = Int(seconds.truncatingRemainder(dividingBy: 60))
        let minutesString = String(format: "%02d", minutesRemaining)
        let secondsString = String(format: "%02d", secondsRemaining)
        label.text = "\(minutesString):\(secondsString)"
    }

    private func requestAuthorization() async -> Bool {
        switch alarmManager.authorizationState {
        case .notDetermined:
            do {
                let state = try await alarmManager.requestAuthorization()
                return state == .authorized
            } catch {
                print("Error occurred while requesting authorization: \(error)")
                return false
            }
        case .denied:
            return false
        case .authorized:
            return true
        @unknown default:
            return false
        }
    }

    private func setupAlarm() {
        guard let date = futureDate else { return }
        let alertContent = AlarmPresentation.Alert(title: "Tea's Ready!")
        
        let attributes = AlarmAttributes<TeaCategory>(
            presentation: AlarmPresentation(alert: alertContent),
            tintColor: Color.accentColor)
        
        let configuration = AlarmManager.AlarmConfiguration.alarm(schedule: Alarm.Schedule.fixed(date), attributes: attributes)

        let id = UUID()
        alarmID = id

        Task {
            do {
                let alarm = try await alarmManager.schedule(id: id, configuration: configuration)
            } catch {
                print(error)
            }
        }
    }

    private func stopAlarm() {
        guard let id = alarmID else { return }
        try? alarmManager.stop(id: id)
        alarmID = nil
    }
}



















// step 3: add these presets to the timer and a way to pick a selection
// herbal tea = 6 minutes   button color: red
// black/puerh tea = 5 minutes  button color: black/dark brown
// oolong/yellow tea = 3 minutes    button color: yellow/tan
// green/white tea = 2 minutes  button color: green/off white
// gong fu cha = 15 seconds + a button that restarts timer and adds 10 seconds to the original count every time (ex. 15,25,35...)   button color: ?
