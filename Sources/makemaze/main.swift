import Foundation
import Maze
import SwiftImage
import Commander

struct IllegalScaleError: Error, CustomStringConvertible {
    let scale: Int
    var description: String {
        "The scale must be greater than or equal to 1: scale = \(scale)"
    }
}

command(
    Option("width", default: 1023, flag: "w", description: "Width of the created maze"),
    Option("height", default: 1023, flag: "h", description: "Height of the created maze"),
    Option("scale", default: 1, flag: "s", description: "Scale of the output image") {
        guard $0 >= 1 else { throw IllegalScaleError(scale: $0) }
        return $0
    }
) { width, height, scale in
    let maze: Maze<UInt8> = try .makeMaze(width: width, height: height, start: 255, goal: 255, path: 255, wall: 0)
    var mazeImage: Image<UInt8> = .init(width: maze.width, height: maze.height, pixels: maze)
    mazeImage = mazeImage.resizedTo(width: width * scale, height: height * scale, interpolatedBy: .nearestNeighbor)
    let data: Data = mazeImage.data(using: .png)!
    FileHandle.standardOutput.write(data)
}.run()
