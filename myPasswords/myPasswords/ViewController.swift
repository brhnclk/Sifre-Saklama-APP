//
//  ViewController.swift
//  myPasswords
//
//  Created by Burhan Çelik on 19.02.2025.
//
import UIKit
class ViewController: UIViewController {
    @IBOutlet weak var cardAdder: UIButton!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var lockButton: UIButton!
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private var allCards: [UIView] = []
    private var isUnlocked = false {
        didSet {
            updateUILockState()
        }
    }
    private var cards: [Card] = [] {
        didSet {
            saveCards()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupInitialState()
        loadCards()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
            view.addGestureRecognizer(tapGesture)
    }
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: cardAdder.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        cardAdder.addTarget(self, action: #selector(addCardButtonTapped), for: .touchUpInside)
    }
    private func setupSearchBar() {
        searchBar.backgroundColor = .gray.withAlphaComponent(0.2)
        searchBar.textColor = .black
        searchBar.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        let placeholderText = "Ara..."
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        searchBar.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
    }
    @objc private func searchTextChanged() {
        filterCards(with: searchBar.text ?? "")
    }
    private func filterCards(with searchText: String) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if searchText.isEmpty {
            allCards.forEach { stackView.addArrangedSubview($0) }
        } else {
            allCards.forEach { cardView in
                if let titleLabel = cardView.subviews.first as? UILabel,
                   let title = titleLabel.text?.lowercased(),
                   title.contains(searchText.lowercased()) {
                    stackView.addArrangedSubview(cardView)
                }
            }
        }
    }
    private func loadCards() {
        if let savedCardsData = UserDefaults.standard.data(forKey: "SavedCards"),
           let decodedCards = try? JSONDecoder().decode([Card].self, from: savedCardsData) {
            cards = decodedCards
            cards.forEach { card in
                let cardView = createCardView(with: card)
                allCards.append(cardView)
                if searchBar.text?.isEmpty ?? true {
                    stackView.addArrangedSubview(cardView)
                }
            }
        }
    }
    private func saveCards() {
        if let encodedData = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encodedData, forKey: "SavedCards")
        }
    }
    private func createCardView(with card: Card? = nil) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = card?.colorIndex != nil ? Card.getColor(for: card!.colorIndex) : .systemGray6
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        let titleLabel = UILabel()
        titleLabel.text = card?.title ?? "İsimsiz Kayıt"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let subtitleLabel = UILabel()
        subtitleLabel.text = card?.subtitle ?? ""
        subtitleLabel.textColor = .gray
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 100),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        cardView.addGestureRecognizer(tapGesture)
        cardView.isUserInteractionEnabled = isUnlocked
        cardView.accessibilityIdentifier = card?.additionalText
        cardView.accessibilityLabel = card?.password
        return cardView
    }
    @objc private func addCardButtonTapped() {
        let cardView = createCardView()
        allCards.append(cardView)
        let newCard = Card(
            title: "İsimsiz Kayıt",
            subtitle: "",
            additionalText: "",
            password: "",
            colorIndex: 0
        )
        cards.append(newCard)
        if let searchText = searchBar.text, !searchText.isEmpty {
            if let titleLabel = cardView.subviews.first as? UILabel,
               let title = titleLabel.text?.lowercased(),
               title.contains(searchText.lowercased()) {
                stackView.addArrangedSubview(cardView)
            }
        } else {
            stackView.addArrangedSubview(cardView)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    private func setupInitialState() {
        isUnlocked = false
        lockButton.setImage(UIImage(systemName: "lock.fill"), for: .normal)
        lockButton.addTarget(self, action: #selector(lockButtonTapped), for: .touchUpInside)
    }
    private func updateUILockState() {
        cardAdder.isEnabled = isUnlocked
        searchBar.isEnabled = isUnlocked
        let lockImage = isUnlocked ? "lock.open.fill" : "lock.fill"
        lockButton.setImage(UIImage(systemName: lockImage), for: .normal)
        allCards.forEach { cardView in
            cardView.isUserInteractionEnabled = isUnlocked
        }
    }
    @objc private func lockButtonTapped() {
        if isUnlocked {
            isUnlocked = false
        } else {
            let pinVC = PinViewController()
            pinVC.delegate = self
            pinVC.modalPresentationStyle = .pageSheet
            if let sheet = pinVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
            present(pinVC, animated: true)
        }
    }
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let cardView = gesture.view else { return }
        let editVC = CardEditViewController()
        editVC.modalPresentationStyle = .pageSheet
        editVC.delegate = self
        if let titleLabel = cardView.subviews.first as? UILabel {
            editVC.currentTitle = titleLabel.text
        }
        if let subtitleLabel = cardView.subviews[1] as? UILabel {
            editVC.currentSubtitle = subtitleLabel.text
        }
        editVC.currentAdditionalText = cardView.accessibilityIdentifier
        editVC.currentPassword = cardView.accessibilityLabel
        editVC.currentBackgroundColor = cardView.backgroundColor
        if let index = stackView.arrangedSubviews.firstIndex(of: cardView) {
            editVC.tag = index
        }
        if let sheet = editVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(editVC, animated: true)
    }
}
// MARK: - CardEditViewControllerDelegate
extension ViewController: CardEditViewControllerDelegate {
    func cardEditViewController(_ controller: CardEditViewController, didSaveWithTitle title: String, subtitle: String, additionalText: String, password: String, backgroundColor: UIColor) {
        guard controller.tag < allCards.count else { return }
        let cardView = allCards[controller.tag]
        if let titleLabel = cardView.subviews.first as? UILabel {
            titleLabel.text = title.isEmpty ? "İsimsiz Kayıt" : title
        }
        if let subtitleLabel = cardView.subviews[1] as? UILabel {
            subtitleLabel.text = subtitle
        }
        cardView.accessibilityIdentifier = additionalText
        cardView.accessibilityLabel = password
        cardView.backgroundColor = backgroundColor
        let updatedCard = Card(
            title: title.isEmpty ? "İsimsiz Kayıt" : title,
            subtitle: subtitle,
            additionalText: additionalText,
            password: password,
            colorIndex: Card.getColorIndex(for: backgroundColor)
        )
        cards[controller.tag] = updatedCard
        filterCards(with: searchBar.text ?? "")
    }
    func cardEditViewController(_ controller: CardEditViewController, didRequestDeleteAtIndex index: Int) {
        guard index < allCards.count else { return }
        allCards[index].removeFromSuperview()
        allCards.remove(at: index)
        cards.remove(at: index)
        filterCards(with: searchBar.text ?? "")
    }
}
// MARK: - PinViewControllerDelegate
extension ViewController: PinViewControllerDelegate {
    func pinValidationSucceeded() {
        isUnlocked = true
    }
}
