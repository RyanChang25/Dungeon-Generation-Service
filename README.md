# Dungeon-Generation-Service

## Overview
Dungeon Generation Service is a service that uses a simple algorithim I created to semi-procedurally generate dungeon rooms. This generation relies on having chunks within the ServerStorage, which are then randomly inserted into the game to semi-procedurally generate the dungeon. There are 5 categories of chunks: Start, Front, Right Corners, Left Corners, and End. Each chunk has its own set of random layouts that is used when called by the service, giving the dungeon a sense of *procedural generation*. The algorithim itself uses a pretty practical head-on approach; all it does is generates random chunks based on the last chunk. It also has built in limitations, to make sure the dungeon layout doesn't *loop* into itself. Again, due to this simplicity of it, the dungeon layout itself only goes *forward*, (Based on the start chunk) which can lead to more possibilities to update this service in the future. *(Can send RBXL file upon request)*

## Basic Usage
```
-- Note: This will not work if you do not have correct Folder Structure and naming conventions! If interested on actual implementation, feel free to ask me!
DungeonGenerationService:Generate(10, 3, 60, Vector3.new(90, -1, -240)) -->>: Number of Rooms, Room Chunks, Floor Size, Start CFrame
```

## Important Links
**Game Demo - https://www.roblox.com/games/9127181027/Accelerator-Game-Concept**
