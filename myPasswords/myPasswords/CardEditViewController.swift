import UIKit
protocol CardEditViewControllerDelegate: AnyObject {
    func cardEditViewController(_ controller: CardEditViewController, didSaveWithTitle title: String, subtitle: String, additionalText: String, password: String, backgroundColor: UIColor)
    func cardEditViewController(_ controller: CardEditViewController, didRequestDeleteAtIndex index: Int)
}
class CardEditViewController: UIViewController {
    weak var delegate: CardEditViewControllerDelegate?
    var tag: Int = 0
    var currentTitle: String?
    var currentSubtitle: String?
    var currentAdditionalText: String?
    var currentPassword: String?
    var currentBackgroundColor: UIColor?
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Başlık"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemGray5
        return textField
    }()
    private let subtitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Alt Bilgi"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemGray5
        return textField
    }()
    private let additionalTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Ek Bilgi"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemGray5
        return textField
    }()
    private let passwordContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Şifre"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemGray5
        return textField
    }()
    private let togglePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let copyPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let colorSegmentedControl: UISegmentedControl = {
        let items = ["Gri", "Mavi", "Yeşil", "Pembe", "Kırmızı", "Sarı", "Turkuaz"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.backgroundColor = .systemGray2
        control.selectedSegmentTintColor = .white
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kaydet", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kaydı Sil", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupExistingData()
    }
    private func setupUI() {
        view.backgroundColor = .white
        passwordContainerView.addSubview(passwordTextField)
        passwordContainerView.addSubview(togglePasswordButton)
        passwordContainerView.addSubview(copyPasswordButton)
        view.addSubview(titleTextField)
        view.addSubview(subtitleTextField)
        view.addSubview(additionalTextField)
        view.addSubview(passwordContainerView)
        view.addSubview(colorSegmentedControl)
        view.addSubview(saveButton)
        view.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            subtitleTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            subtitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            subtitleTextField.heightAnchor.constraint(equalToConstant: 44),
            additionalTextField.topAnchor.constraint(equalTo: subtitleTextField.bottomAnchor, constant: 16),
            additionalTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            additionalTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            additionalTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordContainerView.topAnchor.constraint(equalTo: additionalTextField.bottomAnchor, constant: 16),
            passwordContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordContainerView.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.topAnchor.constraint(equalTo: passwordContainerView.topAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor),
            passwordTextField.bottomAnchor.constraint(equalTo: passwordContainerView.bottomAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: togglePasswordButton.leadingAnchor, constant: -8),
            togglePasswordButton.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            togglePasswordButton.trailingAnchor.constraint(equalTo: copyPasswordButton.leadingAnchor, constant: -8),
            togglePasswordButton.widthAnchor.constraint(equalToConstant: 30),
            togglePasswordButton.heightAnchor.constraint(equalToConstant: 30),
            copyPasswordButton.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            copyPasswordButton.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor),
            copyPasswordButton.widthAnchor.constraint(equalToConstant: 30),
            copyPasswordButton.heightAnchor.constraint(equalToConstant: 30),
            colorSegmentedControl.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 16),
            colorSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            colorSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.topAnchor.constraint(equalTo: colorSegmentedControl.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            deleteButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        copyPasswordButton.addTarget(self, action: #selector(copyPasswordTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    private func setupExistingData() {
        titleTextField.text = currentTitle
        subtitleTextField.text = currentSubtitle
        additionalTextField.text = currentAdditionalText
        passwordTextField.text = currentPassword
        if let currentColor = currentBackgroundColor {
            if currentColor.isEqual(UIColor.systemGray6) {
                colorSegmentedControl.selectedSegmentIndex = 0
            } else if currentColor.isEqual(UIColor.systemBlue.withAlphaComponent(0.5)) {
                colorSegmentedControl.selectedSegmentIndex = 1
            } else if currentColor.isEqual(UIColor.systemGreen.withAlphaComponent(0.5)) {
                colorSegmentedControl.selectedSegmentIndex = 2
            } else if currentColor.isEqual(UIColor.systemPink.withAlphaComponent(0.5)) {
                colorSegmentedControl.selectedSegmentIndex = 3
            } else if currentColor.isEqual(UIColor.systemRed.withAlphaComponent(0.5)){
                colorSegmentedControl.selectedSegmentIndex = 4
            } else if currentColor.isEqual(UIColor.systemYellow.withAlphaComponent(0.5)){
                colorSegmentedControl.selectedSegmentIndex = 5
            } else if currentColor.isEqual(UIColor.systemCyan.withAlphaComponent(0.5)){
                colorSegmentedControl.selectedSegmentIndex = 6
            }
        }
    }
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        togglePasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    @objc private func copyPasswordTapped() {
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        UIPasteboard.general.string = password
        let originalImage = copyPasswordButton.imageView?.image
        copyPasswordButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        copyPasswordButton.tintColor = .systemGreen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.copyPasswordButton.setImage(originalImage, for: .normal)
            self.copyPasswordButton.tintColor = .gray
        }
    }
    private func getSelectedColor() -> UIColor {
        switch colorSegmentedControl.selectedSegmentIndex {
        case 0:
            return .systemGray6
        case 1:
            return .systemBlue.withAlphaComponent(0.5)
        case 2:
            return .systemGreen.withAlphaComponent(0.5)
        case 3:
            return .systemPink.withAlphaComponent(0.5)
        case 4:
            return .systemRed.withAlphaComponent(0.5)
        case 5:
            return .systemYellow.withAlphaComponent(0.5)
        case 6:
            return .systemCyan.withAlphaComponent(0.5)
        default:
            return .systemGray6
        }
    }
    @objc private func saveButtonTapped() {
        let title = titleTextField.text ?? ""
        let subtitle = subtitleTextField.text ?? ""
        let additionalText = additionalTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let color = getSelectedColor()
        delegate?.cardEditViewController(self, didSaveWithTitle: title, subtitle: subtitle, additionalText: additionalText, password: password, backgroundColor: color)
        dismiss(animated: true)
    }
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Kaydı Sil",
            message: "Bu kaydı silmek istediğinizden emin misiniz?",
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.cardEditViewController(self, didRequestDeleteAtIndex: self.tag)
            self.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
} 
