import Foundation
import SwiftImage

let defaultWidth = 1023
let defaultHeight = 1023

let wall:  RGBA<UInt8> = .init(0x000000FF)
let path:  RGBA<UInt8> = .init(0xFFFFFFFF)
let start: RGBA<UInt8> = .init(0x0000FFFF)
let goal:  RGBA<UInt8> = .init(0x00FF00FF)

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
var maze: Image<RGBA<UInt8>> = Image(width: width, height: height) { x, y in
    if x == 0 || y == 0 || x == width - 1 || y == height - 1 {
        return wall
    } else {
        return path
    }
}

maze[1, 1] = start
maze[width - 2, height - 2] = goal

if Bool.random() {
    maze[2, 1] = wall
    maze[2, 2] = wall
} else {
    maze[1, 2] = wall
    maze[2, 2] = wall
}

if Bool.random() {
    maze[width - 3, height - 2] = wall
    maze[width - 3, height - 3] = wall
} else {
    maze[width - 2, height - 3] = wall
    maze[width - 3, height - 3] = wall
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

wallsMaking: while let pointToStartWall = pointsToStartWall.popLast() {
    guard maze[pointToStartWall] == path else { continue }
    
    var wallPoints: [Point] = []
    var wallPointSet: Set<Point> = []
    
    var point = pointToStartWall
    wallMaking: while true {
        maze[point] = wall
        wallPoints.append(point)
        wallPointSet.insert(point)

        for direction in directions.shuffled() {
            guard maze[point + direction] == path else { continue }
            if wallPointSet.contains(point + direction * 2) { continue }
            
            point += direction
            maze[point] = wall
            
            point += direction
            if maze[point] == wall {
                continue wallsMaking
            } else {
                continue wallMaking
            }
        }
        
        wallPoints.removeLast()
        point = wallPoints.removeLast()
    }
}

// Output
let data: Data = maze.data(using: .png)!
FileHandle.standardOutput.write(data)
