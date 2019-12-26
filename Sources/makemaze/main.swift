import Foundation
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
    var maze: Image<MazeCell> = try .init(width: width, height: height)
    maze = maze.resizedTo(width: width * scale, height: height * scale)
    let data: Data = maze.map { $0.color }.data(using: .png)!
    FileHandle.standardOutput.write(data)
}.run()
