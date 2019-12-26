import Foundation
import SwiftImage

let defaultWidth = 1023
let defaultHeight = 1023

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

// Making a maze
let maze: Image<MazeCell> = .init(width: width, height: height)

// Output
let data: Data = maze.map { $0.color }.data(using: .png)!
FileHandle.standardOutput.write(data)
