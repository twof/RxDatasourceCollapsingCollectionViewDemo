import UIKit

class SimpleHeaderView: UICollectionReusableView {
    public static let identifier = String(describing: SimpleHeaderView.self)

    public var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var didTapAction: () -> Void = {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .blue
        title.text = ""
        setupViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupGesture(didTapAction: @escaping () -> Void) {
        self.didTapAction = didTapAction
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeader))
        self.addGestureRecognizer(tapGesture)
    }

    func setupViews() {
        self.addSubview(title)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.title.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.title.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    @objc func didTapHeader() {
        didTapAction()
    }
}
