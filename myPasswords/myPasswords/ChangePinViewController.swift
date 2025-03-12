import UIKit
protocol ChangePinViewControllerDelegate: AnyObject {
    func pinChangeSucceeded()
}
class ChangePinViewController: UIViewController {
    weak var delegate: ChangePinViewControllerDelegate?
    private var currentTextField: UITextField?
    private var oldPin = ""
    private var newPin = ""
    private var confirmPin = ""
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let oldPinLabel: UILabel = {
        let label = UILabel()
        label.text = "Mevcut PIN"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()
    private let oldPinDisplay: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    private let oldPinErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "✗"
        label.textColor = .red
        label.font = .systemFont(ofSize: 24)
        label.isHidden = true
        return label
    }()
    private let newPinLabel: UILabel = {
        let label = UILabel()
        label.text = "Yeni PIN"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()
    private let newPinDisplay: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    private let newPinErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "✗"
        label.textColor = .red
        label.font = .systemFont(ofSize: 24)
        label.isHidden = true
        return label
    }()
    private let confirmPinLabel: UILabel = {
        let label = UILabel()
        label.text = "Yeni PIN (Tekrar)"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()
    private let confirmPinDisplay: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24)
        return label
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.numberOfLines = 0
        label.isHidden = true
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
    private let oldPinTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.textColor = .gray
        let placeholderText = "Mevcut PIN"
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        return textField
    }()
    private let newPinTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.textColor = .gray
        let placeholderText = "Yeni PIN"
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        return textField
    }()
    private let confirmPinTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.textColor = .gray
        let placeholderText = "Yeni PIN (Tekrar)"
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
            textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        return textField
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        oldPinTextField.inputView = UIView()
        newPinTextField.inputView = UIView()
        confirmPinTextField.inputView = UIView()
        resetAllFields()
    }
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(stackView)
        view.addSubview(numberPadStackView)
        let oldPinStack = UIStackView(arrangedSubviews: [oldPinTextField, oldPinErrorLabel])
        oldPinStack.axis = .horizontal
        oldPinStack.spacing = 8
        oldPinStack.alignment = .center
        let newPinStack = UIStackView(arrangedSubviews: [newPinTextField, newPinErrorLabel])
        newPinStack.axis = .horizontal
        newPinStack.spacing = 8
        newPinStack.alignment = .center
        [oldPinLabel, oldPinStack, newPinLabel, newPinStack, confirmPinLabel, confirmPinTextField, messageLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        [oldPinTextField, newPinTextField, confirmPinTextField].forEach { textField in
            textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        setupNumberPad()
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            numberPadStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            numberPadStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            numberPadStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            numberPadStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            oldPinTextField.heightAnchor.constraint(equalToConstant: 44),
            newPinTextField.heightAnchor.constraint(equalToConstant: 44),
            confirmPinTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    private func setupTextFields() {
        [oldPinTextField, newPinTextField, confirmPinTextField].forEach { textField in
            textField.addTarget(self, action: #selector(textFieldTapped), for: .editingDidBegin)
            textField.delegate = self
        }
    }
    @objc private func textFieldTapped(_ textField: UITextField) {
        currentTextField = textField
    }
    private func resetAllFields() {
        oldPin = ""
        newPin = ""
        confirmPin = ""
        oldPinTextField.text = ""
        newPinTextField.text = ""
        confirmPinTextField.text = ""
        clearBackgroundColors()
        oldPinErrorLabel.isHidden = true
        newPinErrorLabel.isHidden = true
        currentTextField = oldPinTextField
        oldPinTextField.becomeFirstResponder()
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
        guard let currentField = currentTextField else { return }
        clearBackgroundColors()
        messageLabel.isHidden = true
        if currentField === oldPinTextField && oldPin.count < 4 {
            oldPin += "\(sender.tag)"
            oldPinTextField.text = oldPin
            if oldPin.count == 4 {
                currentTextField = newPinTextField
                newPinTextField.becomeFirstResponder()
            }
        }
        else if currentField === newPinTextField && newPin.count < 4 {
            newPin += "\(sender.tag)"
            newPinTextField.text = newPin
            if newPin.count == 4 {
                currentTextField = confirmPinTextField
                confirmPinTextField.becomeFirstResponder()
            }
        }
        else if currentField === confirmPinTextField && confirmPin.count < 4 {
            confirmPin += "\(sender.tag)"
            confirmPinTextField.text = confirmPin
            if confirmPin.count == 4 {
                validatePins()
            }
        }
    }
    @objc private func deleteButtonTapped() {
        guard let currentField = currentTextField else { return }
        if currentField === oldPinTextField && !oldPin.isEmpty {
            oldPin.removeLast()
            oldPinTextField.text = oldPin
        }
        else if currentField === newPinTextField && !newPin.isEmpty {
            newPin.removeLast()
            newPinTextField.text = newPin
        }
        else if currentField === confirmPinTextField && !confirmPin.isEmpty {
            confirmPin.removeLast()
            confirmPinTextField.text = confirmPin
        }
        oldPinErrorLabel.isHidden = true
        newPinErrorLabel.isHidden = true
        messageLabel.isHidden = true
    }
    private func validatePins() {
        guard oldPin.count == 4, newPin.count == 4, confirmPin.count == 4 else {
            showError("Tüm PIN'ler 4 haneli olmalıdır!")
            resetAllFields()
            return
        }
        if oldPin != UserDefaults.savedPIN {
            oldPinErrorLabel.isHidden = false
            oldPinTextField.backgroundColor = .systemPink.withAlphaComponent(0.3)
            showError("❌")
            oldPin = ""
            newPin = ""
            confirmPin = ""
            oldPinTextField.text = ""
            newPinTextField.text = ""
            confirmPinTextField.text = ""
            currentTextField = oldPinTextField
            oldPinTextField.becomeFirstResponder()
            return
        }
        if newPin != confirmPin {
            newPinErrorLabel.isHidden = false
            newPinTextField.backgroundColor = .systemPink.withAlphaComponent(0.3)
            confirmPinTextField.backgroundColor = .systemPink.withAlphaComponent(0.3)
            showError("❌")
            newPin = ""
            confirmPin = ""
            newPinTextField.text = ""
            confirmPinTextField.text = ""
            currentTextField = newPinTextField
            newPinTextField.becomeFirstResponder()
            return
        }
        if newPin == oldPin {
            newPinErrorLabel.isHidden = false
            newPinTextField.backgroundColor = .systemPink.withAlphaComponent(0.3)
            showError("❌")
            newPin = ""
            confirmPin = ""
            newPinTextField.text = ""
            confirmPinTextField.text = ""
            currentTextField = newPinTextField
            newPinTextField.becomeFirstResponder()
            return
        }
        clearBackgroundColors()
        UserDefaults.savedPIN = newPin
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.delegate?.pinChangeSucceeded()
            self?.dismiss(animated: true)
        }
    }
    private func showError(_ message: String) {
        messageLabel.text = message
        messageLabel.textColor = .systemRed
        messageLabel.isHidden = false
    }
    private func clearBackgroundColors() {
        oldPinTextField.backgroundColor = .clear
        newPinTextField.backgroundColor = .clear
        confirmPinTextField.backgroundColor = .clear
    }
    private func resetCurrentField() {
        if currentTextField === oldPinTextField {
            oldPin = ""
            oldPinTextField.text = ""
        }
        currentTextField?.becomeFirstResponder()
    }
    private func resetNewPins() {
        newPin = ""
        confirmPin = ""
        newPinTextField.text = ""
        confirmPinTextField.text = ""
        currentTextField = newPinTextField
        newPinTextField.becomeFirstResponder()
    }
}
// MARK: - UITextFieldDelegate
extension ChangePinViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        return allowedCharacters.isSuperset(of: characterSet) && newLength <= 4
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === oldPinTextField {
            oldPin = textField.text ?? ""
        } else if textField === newPinTextField {
            newPin = textField.text ?? ""
        } else if textField === confirmPinTextField {
            confirmPin = textField.text ?? ""
        }
    }
} 
