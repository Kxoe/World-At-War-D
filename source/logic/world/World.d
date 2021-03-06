module logic.world.World;

import std.file;
import std.json;
import std.math;
import std.random;

import logic.world.Tile;

/**
 * The world, mostly as a two-dimensional array of tiles
 */
class World {

    Tile[][] tiles; ///The tiles of the world

    alias tiles this; //Allows the world to be indexed to get tiles at coordinates

    /**
     * Constructs a new world, using the given world parameters
     * Randomly places ncontinents land tiles, then places land tiles
     * next to existing land with a higher chance the more tiles there are surrounding
     * until the world is about one third land
     * TODO: Add config file to determine worldgen parameters
     * TODO: Make continent generation more evenly distributed by bounding boxes
     */
    this(int ncontinents, int nrows, int ncols){
        Tile[] blankArray;
        foreach(x; 0..nrows) {
            tiles ~= blankArray.dup;
            foreach(y; 0..ncols) {
                tiles[x] ~= new Tile(Terrain.WATER, new Coordinate(x, y));
            }
        }
        foreach(i; 0..ncontinents) {
            tiles[uniform(0, nrows - 1)][uniform(0, ncols - 1)].terrain = Terrain.LAND;
        }
        int generated = ncontinents;
        double correlation;
        while (generated < (nrows * ncols) / 3) {
            foreach(x; 0..tiles.length) {
                foreach(y; 0..tiles[x].length) {
                    if(tiles[x][y].terrain != Terrain.LAND) {
                        correlation = 0;
                        if(y < tiles[x].length - 1 && tiles[x][y+1].terrain == Terrain.LAND) {
                            correlation += 0.20;
                        }
                        if(y > 0 && tiles[x][y-1].terrain == Terrain.LAND) {
                            correlation += 0.20;
                        }
                        if(x < tiles.length - 1 && tiles[x+1][y].terrain == Terrain.LAND) {
                            correlation += 0.20;
                        }
                        if(x > 0 && tiles[x-1][y].terrain == Terrain.LAND) {
                            correlation += 0.20;
                        }
                        if(uniform(0.0, 1.0) < correlation) {
                            tiles[x][y].terrain = Terrain.LAND;
                            generated += 1;
                        }
                    }
                }
            }
        }
    }

    /**
     * Creates the world based on a custom scenario that is json encoded
     */
    this(string jsonFilename) {
        string fileText = cast(string)read!string(jsonFilename);
        JSONValue json = parseJSON(fileText);
        for(int x; x < json["world"]["terrain"].array.length; x++) {
            tiles ~= null;
            for(int y; y < json["world"]["terrain"][x].array.length; y++) {
                tiles[x] ~= new Tile(cast(Terrain)(cast(int)json["world"]["terrain"][y][x].integer), new Coordinate(x, y));
            }
        }
    }

    /**
     * Returns the tile in the world at the given coordinate
     */
    Tile getTileAt(Coordinate location) {
        if(location.x <= tiles.length - 1 
                && location.x >= 0
                && location.y <= tiles[location.x].length - 1
                && location.y >= 0) {
            return tiles[location.x][location.y];
        } 
        return null;
    }
}