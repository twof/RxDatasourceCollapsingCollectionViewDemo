import RxDataSources

struct SimpleData: Equatable, IdentifiableType {
    typealias Identity = String
    var identity : Identity { return title }

    let title: String
}
