public struct Maze<Cell> {
    public let width: Int
    public let height: Int
    @usableFromInline
    var cells: [Cell]
    
    @inlinable
    public init(width: Int, height: Int, cells: [Cell]) {
        precondition(width >= 0, "`width` cannot be negative: width = \(width)")
        precondition(height >= 0, "`height` cannot be negative: height = \(height)")
        precondition(cells.count == width * height, "`cells.count` must be equal to `width * height`: cells.count = \(cells.count), width = \(width), height = \(height), width * height = \(width * height)")
        
        self.width = width
        self.height = height
        self.cells = cells
    }
    
    @inlinable
    public var xRange: Range<Int> { 0 ..< width }
    @inlinable
    public var yRange: Range<Int> { 0 ..< height }
    
    @inlinable
    func cellIndexAt(x: Int, y: Int) -> Int {
        precondition(xRange.contains(x))
        precondition(yRange.contains(y))
        return y * width + x
    }
    
    @inlinable
    public subscript(x: Int, y: Int) -> Cell {
        get { cells[cellIndexAt(x: x, y: y)] }
        set { cells[cellIndexAt(x: x, y: y)] = newValue }
    }
}

extension Maze {
    @inlinable
    public func map<T>(_ body: @escaping (Cell) throws -> T) rethrows -> Maze<T> {
        .init(width: width, height: height, cells: try cells.map(body))
    }
}

extension Maze: Sequence {
    @inlinable
    public func makeIterator() -> IndexingIterator<[Cell]> {
        cells.makeIterator()
    }
}
