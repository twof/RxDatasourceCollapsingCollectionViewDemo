import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    
    let collectionView: UICollectionView = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.itemSize = CGSize(width: 300, height: 60)
        collectionLayout.headerReferenceSize = CGSize(width: 300, height: 60)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .white

        return collection
    }()

    let dataDict = Variable([
        "Hello":  SimpleSectionModel(
            header: "Hello",
            isCollapsed: false,
            items: [
                SimpleData(title: "world"),
                SimpleData(title: "Anything else")
            ]
        ),
        "Second": SimpleSectionModel(
            header: "Second",
            isCollapsed: true,
            items: [
                SimpleData(title: "aaaaa"),
                SimpleData(title: "BBBBBB")
            ]
        ),
        "Third": SimpleSectionModel(
            header: "Third",
            isCollapsed: false,
            items: [
                SimpleData(title: "aaaaaa"),
                SimpleData(title: "BBBBB")
            ]
        )
    ])

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setup() {
        setupViews()
        setupConstraints()
        rxSetup()
    }
    
    func rxSetup() {
        let datasource = RxCollectionViewSectionedAnimatedDataSource<SimpleSectionModel>.init(configureCell: { datasource, collectionView, indexpath, element in

            guard let cell
                = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexpath) as? SimpleCollectionViewCell
                else { return UICollectionViewCell() }
            cell.title.text = element.title
            return cell
        }, configureSupplementaryView: { datasource, collectionView, supplementaryIdentifier, indexpath in
            if supplementaryIdentifier == UICollectionElementKindSectionHeader {
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionElementKindSectionHeader,
                    withReuseIdentifier: SimpleHeaderView.identifier,
                    for: indexpath
                )

                guard let header = view as? SimpleHeaderView else {
                    assertionFailure("Expected a SimpleHeaderView.")
                    return UICollectionReusableView()
                }

                let headerTitle: String = datasource.sectionModels[indexpath.section].header

                header.title.text = headerTitle
                header.setupGesture {
                    if let oldValue = self.dataDict.value[headerTitle] {
                        self.dataDict.value[headerTitle] = SimpleSectionModel(header: oldValue.header, isCollapsed: !oldValue.isCollapsed, items: oldValue.items)
                    }
                }

                return header
            }

            return UICollectionReusableView()
        })

        dataDict.asObservable()
            .map { $0.values }
            .map { (sections) in
            return sections.map { (model) in
                return model.isCollapsed
                    ? SimpleSectionModel(header: model.header, isCollapsed: model.isCollapsed, items: [])
                    : model
            }
        }.bind(to: collectionView.rx.items(dataSource: datasource))
        .disposed(by: disposeBag)
    }
    
    func setupViews() {
        collectionView.register(SimpleCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(
            SimpleHeaderView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: SimpleHeaderView.identifier
        )
        self.view.addSubview(collectionView)

        let refreshControl = UIRefreshControl()
        self.collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshCollection), for: .valueChanged)
    }

    func setupConstraints() {
         NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func refreshCollection(_ sender: Any) {
       let newData = [
            SimpleSectionModel(
                header: "Hello",
                isCollapsed: false,
                items: [
                    SimpleData(title: "world"),
                    SimpleData(title: "Anything else")
                ]
            ),
            SimpleSectionModel(
                header: "Second",
                isCollapsed: false,
                items: [
                    SimpleData(title: "aaaaa"),
                    SimpleData(title: "BBBBBB")
                ]
            ),
            SimpleSectionModel(
                header: "Third",
                isCollapsed: false,
                items: [
                    SimpleData(title: "aaaaaa"),
                    SimpleData(title: "BBBBB")
                ]
            ),
            SimpleSectionModel(
                header: "Fourth",
                isCollapsed: false,
                items: [
                    SimpleData(title: "ffff"),
                    SimpleData(title: "tttttt")
                ]
            )
        ]

        dataDict.value = dataDict.value.merge(with: newData)
        self.collectionView.refreshControl?.endRefreshing()
    }
}

extension Dictionary where Value == SimpleSectionModel, Key == String {
    func merge(with collection: [SimpleSectionModel]) -> [String: SimpleSectionModel] {
        var copy = self

        for element in collection {
            if self.keys.contains(element.header) {
                guard let oldValue = self[element.header] else { fatalError() }
                copy[element.header] = SimpleSectionModel(header: element.header, isCollapsed: oldValue.isCollapsed, items: element.items)
            } else {
                copy[element.header] = element
            }
        }

        return copy
    }
}

extension Collection where Element == SimpleSectionModel {
    func merge(with collection: [SimpleSectionModel]) -> [SimpleSectionModel] {
        let both = Array(Set(self + collection))
        let collapsedStateRespected: [SimpleSectionModel] = both.map { section in
            if let found = self.first(where: { section == $0 }) {
                return SimpleSectionModel(header: section.header, isCollapsed: found.isCollapsed, items: section.items)
            } else {
                return section
            }
        }

        return collapsedStateRespected
    }
}


