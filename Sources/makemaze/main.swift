import Foundation
import SwiftImage

let defaultWidth = 1023
let defaultHeight = 1023

extension Image where Pixel == RGBA<UInt8> {
    static let path:  RGBA<UInt8> = .init(0xFFFFFFFF)
    static let wall:  RGBA<UInt8> = .init(0x000000FF)
    static let start: RGBA<UInt8> = .init(0x0000FFFF)
    static let goal:  RGBA<UInt8> = .init(0x00FF00FF)
}

extension Image where Pixel == Int {
    static let path: Int = 0
    static let defaultWall: Int = 1
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
var maze: Image<Int> = Image(width: width, height: height) { x, y in
    if x == 0 || y == 0 || x == width - 1 || y == height - 1 {
        return Image<Int>.defaultWall
    } else {
        return Image<Int>.path
    }
}

if Bool.random() {
    maze[2, 1] = Image<Int>.defaultWall
    maze[2, 2] = Image<Int>.defaultWall
} else {
    maze[1, 2] = Image<Int>.defaultWall
    maze[2, 2] = Image<Int>.defaultWall
}

if Bool.random() {
    maze[width - 3, height - 2] = Image<Int>.defaultWall
    maze[width - 3, height - 3] = Image<Int>.defaultWall
} else {
    maze[width - 2, height - 3] = Image<Int>.defaultWall
    maze[width - 3, height - 3] = Image<Int>.defaultWall
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

var wall: Int = Image<Int>.defaultWall
wallsMaking: while let pointToStartWall = pointsToStartWall.popLast() {
    guard maze[pointToStartWall] == Image<Int>.path else { continue }
    
    wall += 1
    
    var wallPoints: [Point] = []
    
    var point = pointToStartWall
    wallMaking: while true {
        maze[point] = wall
        wallPoints.append(point)

        for direction in directions.shuffled() {
            guard maze[point + direction] == Image<Int>.path else { continue }
            if maze[point + direction * 2] == wall { continue }
            
            point += direction
            maze[point] = wall
            
            point += direction
            if maze[point] == Image<Int>.path {
                continue wallMaking
            } else {
                continue wallsMaking
            }
        }
        
        wallPoints.removeLast()
        point = wallPoints.removeLast()
    }
}

var mazeImage: Image<RGBA<UInt8>> = maze.map { $0 == Image<Int>.path ? Image<RGBA<UInt8>>.path : Image<RGBA<UInt8>>.wall }
mazeImage[1, 1] = Image<RGBA<UInt8>>.start
mazeImage[width - 2, height - 2] = Image<RGBA<UInt8>>.goal

// Output
let data: Data = mazeImage.data(using: .png)!
FileHandle.standardOutput.write(data)
