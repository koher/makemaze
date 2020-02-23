// Making a maze using the algorithm
// explained at https://algoful.com/Archive/Algorithm/MazeExtend

extension Maze {
    @inlinable
    public static func makeMaze(width: Int, height: Int, start: Cell, goal: Cell, path: Cell, wall: Cell) throws -> Maze<Cell> {
        guard width >= 3, width.isOdd, height >= 3, height.isOdd else {
            throw MazeMakingError(width: width, height: height)
        }
        
        var maze = Maze<MazeCell>(
            width: width,
            height: height,
            cells: .init(repeating: .path, count: width * height)
        )
        
        // making walls
        for x in maze.xRange {
            maze[x, maze.yRange.startIndex] = .wall(0)
            maze[x, maze.yRange.endIndex - 1] = .wall(0)
        }
        for y in maze.yRange {
            maze[maze.xRange.startIndex, y] = .wall(0)
            maze[maze.xRange.endIndex - 1, y] = .wall(0)
        }
        
        var pointsToStartWall: [(Int, Int)] = []
        for y in maze.yRange {
            guard y.isEven else { continue }
            for x in maze.xRange {
                guard x.isEven else { continue }
                pointsToStartWall.append((x, y))
            }
        }
        pointsToStartWall.shuffle()

        var wallCount: Int = 0
        wallsMaking: while let (x, y) = pointsToStartWall.popLast() {
            guard maze[x, y] == .path else { continue }
            
            wallCount += 1
            
            var wallPoints: [(Int, Int)] = []
            
            var point = (x, y)
            wallMaking: while true {
                maze[point] = .wall(wallCount)
                wallPoints.append(point)

                for direction in directions.shuffled() {
                    guard maze[point + direction] == .path else { continue }
                    if maze[point + direction * 2] == .wall(wallCount) { continue }
                    
                    point += direction
                    maze[point] = .wall(wallCount)
                    
                    point += direction
                    if maze[point] == .path {
                        continue wallMaking
                    } else {
                        continue wallsMaking
                    }
                }
                
                guard let _ = wallPoints.popLast() else {
                    preconditionFailure("Never reaches here.")
                }
                guard let nextPoint = wallPoints.popLast() else {
                    preconditionFailure("Never reaches here.")
                }
                point = nextPoint
            }
        }
        
        // making start and goal
        maze[maze.xRange.startIndex + 1, maze.yRange.startIndex] = .start
        maze[maze.xRange.endIndex - 2, maze.yRange.endIndex - 1] = .goal
        
        return maze.map { cell in
            switch cell {
            case .start: return start
            case .goal: return goal
            case .path: return path
            case .wall(_): return wall
            }
        }
    }
}

extension Maze {
    @inlinable
    subscript(point: (Int, Int)) -> Cell {
        get { self[point.0, point.1] }
        set { self[point.0, point.1] = newValue }
    }
}

extension Int {
    @inlinable
    var isOdd: Bool {
        !isMultiple(of: 2)
    }
    
    @inlinable
    var isEven: Bool {
        isMultiple(of: 2)
    }
}

@usableFromInline
enum MazeCell: Equatable {
    case start
    case goal
    case path
    case wall(Int)
}

@usableFromInline
struct MazeMakingError: Error, CustomStringConvertible {
    public let width: Int
    public let height: Int
    
    @inlinable
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    @inlinable
    public var description: String {
        "The width and the height must be a odd number greater than or equal to 7: width = \(width), height = \(height)"
    }
}

@usableFromInline
let directions: [(Int, Int)] = [(-1, 0), (0, -1), (1, 0), (0, 1)]

@inlinable
func +(lhs: (Int, Int), rhs: (Int, Int)) -> (Int, Int) {
    return (lhs.0 + rhs.0, lhs.1 + rhs.1)
}

@inlinable
func +=(lhs: inout (Int, Int), rhs: (Int, Int)) {
    lhs = lhs + rhs
}

@inlinable
func *(lhs: (Int, Int), rhs: Int) -> (Int, Int) {
    return (lhs.0 * rhs, lhs.1 * rhs)
}
