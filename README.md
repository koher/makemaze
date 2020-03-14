# makemaze

A command and a library written in Swift to make mazes.

```bash
makemaze -w 127 -h 127 -s 4 > maze.png
```

![created maze](maze.png)

```swift
import Maze

let maze: Maze = try! .makeMaze(width: 15, height: 15, start: "S", goal: "G", path: " ", wall: "#")

for y in maze.yRange {
    for x in maze.xRange {
        print(maze[x, y], terminator: "")
    }
    print()
}
```

```
#S#############
#       # #   #
### ##### ### #
# # #       # #
# # # # # ### #
# #   # #   # #
# # ####### # #
#   #     #   #
# ### ### #####
# #   #       #
# ### # ##### #
#     #     # #
# ### ##### ###
#   #   #     #
#############G#
```

## Command

```
Usage:

    $ makemaze

Options:
    -w, --width [default: 1023] - Width of the created maze
    -h, --height [default: 1023] - Height of the created maze
    -s, --scale [default: 1] - Scale of the output image
```

## Library

```
.package(url: "https://github.com/koher/makemaze.git", from: "0.1.0"),
```

## License

[The MIT License](LICENSE)
