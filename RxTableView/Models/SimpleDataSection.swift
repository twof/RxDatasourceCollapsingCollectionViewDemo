import RxDataSources

struct SimpleSectionModel: Hashable {
    var hashValue: Int {
        return header.hashValue
    }

    var header: String
    var isCollapsed: Bool
    var items: [Item]
}

extension SimpleSectionModel: AnimatableSectionModelType, IdentifiableType {
    typealias Identity = String
    typealias Item = SimpleData

    var identity: Identity { return self.header }

    init(original: SimpleSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

func ==(left: SimpleSectionModel, right: SimpleSectionModel) -> Bool {
    return left.hashValue == right.hashValue
}
