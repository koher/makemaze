import SwiftImage

extension Image where Pixel == MazeCell {
    // Making a maze using the algorithm
    // explained at https://algoful.com/Archive/Algorithm/MazeExtend
    init(width: Int, height: Int) {
        self.init(width: width, height: height) { x, y in
            if x == 0 || y == 0 || x == width - 1 || y == height - 1 {
                return .wall(0)
            } else {
                return .path
            }
        }
        
        makeStart()
        makeGoal()
        makeWalls()
    }
    
    private mutating func makeStart() {
        self[1, 1] = .start
        if Bool.random() {
            self[2, 1] = .wall(0)
            self[2, 2] = .wall(0)
        } else {
            self[1, 2] = .wall(0)
            self[2, 2] = .wall(0)
        }
    }
    
    private mutating func makeGoal() {
        self[width - 2, height - 2] = .goal
        if Bool.random() {
            self[width - 3, height - 2] = .wall(0)
            self[width - 3, height - 3] = .wall(0)
        } else {
            self[width - 2, height - 3] = .wall(0)
            self[width - 3, height - 3] = .wall(0)
        }
    }
    
    private mutating func makeWalls() {
        var pointsToStartWall: [(Int, Int)] = []
        for y in yRange {
            guard y.isMultiple(of: 2) else { continue }
            for x in xRange {
                guard x.isMultiple(of: 2) else { continue }
                pointsToStartWall.append((x, y))
            }
        }
        pointsToStartWall.shuffle()

        var wallCount: Int = 0
        wallsMaking: while let (x, y) = pointsToStartWall.popLast() {
            guard self[x, y] == .path else { continue }
            
            wallCount += 1
            
            var wallPoints: [(Int, Int)] = []
            
            var point = (x, y)
            wallMaking: while true {
                self[point] = .wall(wallCount)
                wallPoints.append(point)

                for direction in directions.shuffled() {
                    guard self[point + direction] == .path else { continue }
                    if self[point + direction * 2] == .wall(wallCount) { continue }
                    
                    point += direction
                    self[point] = .wall(wallCount)
                    
                    point += direction
                    if self[point] == .path {
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
    }
}

enum MazeCell: Equatable {
    case start
    case goal
    case path
    case wall(Int)
    
    var color: RGBA<UInt8> {
        switch self {
        case .start:   return .init(0x0000FFFF)
        case .goal:    return .init(0xFF0000FF)
        case .path:    return .init(0xFFFFFFFF)
        case .wall(_): return .init(0x000000FF)
        }
    }
}

extension Image {
    fileprivate subscript(point: (Int, Int)) -> Pixel {
        get { self[point.0, point.1] }
        set { self[point.0, point.1] = newValue }
    }
}

private let directions: [(Int, Int)] = [(-1, 0), (0, -1), (1, 0), (0, 1)]

fileprivate func +(lhs: (Int, Int), rhs: (Int, Int)) -> (Int, Int) {
    return (lhs.0 + rhs.0, lhs.1 + rhs.1)
}

fileprivate func +=(lhs: inout (Int, Int), rhs: (Int, Int)) {
    lhs = lhs + rhs
}

fileprivate func *(lhs: (Int, Int), rhs: Int) -> (Int, Int) {
    return (lhs.0 * rhs, lhs.1 * rhs)
}
