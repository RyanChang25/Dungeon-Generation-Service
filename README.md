# Dungeon Generation Service

## Overview

`Dungeon Generation Service` is a service that uses a simple algorithm I created to semi-procedurally generate dungeon rooms. This generation relies on having chunks within the `ServerStorage`, which are then randomly inserted into the game to semi-procedurally generate the dungeon. There are 6 categories of chunks: `Start, Front, Right Corners, Left Corners, Room End, and Dungeon End.` Each chunk has its own set of random layouts that are used when called by the service, giving the dungeon a sense of _procedural generation_. This service also has built-in error checks, to make sure the dungeon layout doesn't _loop_ into itself.

`Video Showcase -` https://www.youtube.com/watch?v=GUbLMR5cBiY&t=17s

`(Used in my Fall Accelerator) Demo -` https://www.roblox.com/games/9127181027/Accelerator-Game-Concept
