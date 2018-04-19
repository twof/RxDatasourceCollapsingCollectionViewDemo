import UIKit

class SimpleCollectionViewCell: UICollectionViewCell {
    public var title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
        title.text = ""
        setupViews()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.contentView.addSubview(title)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.title.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.title.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
    }
}
