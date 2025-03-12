import UIKit
protocol PinViewControllerDelegate: AnyObject {
    func pinValidationSucceeded()
}
class PinViewController: UIViewController {
    weak var delegate: PinViewControllerDelegate?
    private var enteredPin = ""
    private let pinDisplayLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let numberPadStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private let changePinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PIN'i Değiştir", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(pinDisplayLabel)
        view.addSubview(messageLabel)
        view.addSubview(numberPadStackView)
        view.addSubview(changePinButton)
        setupNumberPad()
        NSLayoutConstraint.activate([
            pinDisplayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinDisplayLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            messageLabel.topAnchor.constraint(equalTo: pinDisplayLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            numberPadStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),
            numberPadStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            numberPadStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            numberPadStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            changePinButton.topAnchor.constraint(equalTo: numberPadStackView.bottomAnchor, constant: 20),
            changePinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        changePinButton.addTarget(self, action: #selector(changePinButtonTapped), for: .touchUpInside)
    }
    private func setupNumberPad() {
        let numbers = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["", "0", "⌫"]
        ]
        for row in numbers {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.distribution = .fillEqually
            for number in row {
                let button = UIButton(type: .system)
                button.setTitle(number, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 24)
                button.backgroundColor = number.isEmpty ? .clear : .systemGray6
                button.layer.cornerRadius = 8
                if number == "⌫" {
                    button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
                } else if !number.isEmpty {
                    button.tag = Int(number) ?? 0
                    button.addTarget(self, action: #selector(numberButtonTapped(_:)), for: .touchUpInside)
                }
                rowStack.addArrangedSubview(button)
            }
            numberPadStackView.addArrangedSubview(rowStack)
        }
    }
    @objc private func numberButtonTapped(_ sender: UIButton) {
        guard enteredPin.count < 4 else { return }
        enteredPin += "\(sender.tag)"
        updatePinDisplay()
        if enteredPin.count == 4 {
            validatePin()
        }
    }
    @objc private func deleteButtonTapped() {
        guard !enteredPin.isEmpty else { return }
        enteredPin.removeLast()
        updatePinDisplay()
        messageLabel.isHidden = true
    }
    private func updatePinDisplay() {
        pinDisplayLabel.text = String(repeating: "•", count: enteredPin.count)
    }
    private func validatePin() {
        if enteredPin == UserDefaults.savedPIN {
            delegate?.pinValidationSucceeded()
            dismiss(animated: true)
        } else {
            messageLabel.text = "Yanlış PIN! Tekrar deneyin."
            messageLabel.textColor = .systemRed
            messageLabel.isHidden = false
            enteredPin = ""
            updatePinDisplay()
        }
    }
    @objc private func changePinButtonTapped() {
        let changePinVC = ChangePinViewController()
        changePinVC.delegate = self
        changePinVC.modalPresentationStyle = .pageSheet
        if let sheet = changePinVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(changePinVC, animated: true)
    }
}
// MARK: - ChangePinViewControllerDelegate
extension PinViewController: ChangePinViewControllerDelegate {
    func pinChangeSucceeded() {
        messageLabel.text = "PIN başarıyla değiştirildi!"
        messageLabel.textColor = .systemGreen
        messageLabel.isHidden = false
        enteredPin = ""
        updatePinDisplay()
    }
} 
