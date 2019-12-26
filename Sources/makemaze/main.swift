import Foundation
import SwiftImage

let defaultWidth = 1023
let defaultHeight = 1023

enum Cell: Equatable {
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

struct Point: Hashable {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    static func +(lhs: Self, rhs: Self) -> Self {
        return .init(lhs.x + rhs.x, lhs.y + rhs.y)
    }
    
    static func +=(lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    static func *(lhs: Self, rhs: Int) -> Self {
        return .init(lhs.x * rhs, lhs.y * rhs)
    }
}

let directions: [Point] = [
    .init(-1, 0),
    .init(0, -1),
    .init(1, 0),
    .init(0, 1),
]

extension Image {
    subscript(point: Point) -> Pixel {
        get { self[point.x, point.y] }
        set { self[point.x, point.y] = newValue }
    }
}

// Input
let width: Int
let height: Int
do {
    let arguments = CommandLine.arguments
    switch arguments.count {
    case 0, 1:
        width = defaultWidth
        height = defaultHeight
    case 2:
        let size: Int? = Int(arguments[1])
        width =  size ?? defaultWidth
        height = size ?? defaultHeight
    case 3...:
        width = Int(arguments[1]) ?? defaultWidth
        height = Int(arguments[2]) ?? defaultHeight
    default:
        preconditionFailure("Never reaches here.")
    }
    
    if width < 7 || height < 7 || width.isMultiple(of: 2) || height.isMultiple(of: 2) {
        FileHandle.standardError.write("The width and the height must be odd numbers greater than or equal to 7: width = \(width), height = \(height)\n".data(using: .utf8)!)
        exit(1)
    }
}

// Making a maze using the algorithm
// explained at https://algoful.com/Archive/Algorithm/MazeExtend
var maze: Image<Cell> = .init(width: width, height: height) { x, y in
    if x == 0 || y == 0 || x == width - 1 || y == height - 1 {
        return .wall(0)
    } else {
        return .path
    }
}

maze[1, 1] = .start
maze[width - 2, height - 2] = .goal

if Bool.random() {
    maze[2, 1] = .wall(0)
    maze[2, 2] = .wall(0)
} else {
    maze[1, 2] = .wall(0)
    maze[2, 2] = .wall(0)
}

if Bool.random() {
    maze[width - 3, height - 2] = .wall(0)
    maze[width - 3, height - 3] = .wall(0)
} else {
    maze[width - 2, height - 3] = .wall(0)
    maze[width - 3, height - 3] = .wall(0)
}

var pointsToStartWall: [Point] = []
for y in maze.yRange {
    guard y.isMultiple(of: 2) else { continue }
    for x in maze.xRange {
        guard x.isMultiple(of: 2) else { continue }
        pointsToStartWall.append(Point(x, y))
    }
}
pointsToStartWall.shuffle()

var wall: Int = 0
wallsMaking: while let pointToStartWall = pointsToStartWall.popLast() {
    guard maze[pointToStartWall] == .path else { continue }
    
    wall += 1
    
    var wallPoints: [Point] = []
    
    var point = pointToStartWall
    wallMaking: while true {
        maze[point] = .wall(wall)
        wallPoints.append(point)

        for direction in directions.shuffled() {
            guard maze[point + direction] == .path else { continue }
            if maze[point + direction * 2] == .wall(wall) { continue }
            
            point += direction
            maze[point] = .wall(wall)
            
            point += direction
            if maze[point] == .path {
                continue wallMaking
            } else {
                continue wallsMaking
            }
        }
        
        wallPoints.removeLast()
        point = wallPoints.removeLast()
    }
}

// Output
let data: Data = maze.map { $0.color }.data(using: .png)!
FileHandle.standardOutput.write(data)
