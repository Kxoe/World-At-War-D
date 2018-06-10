module graphics.activity.GameActivity;

import d2d;

import graphics;
import logic;

/**
 * The main game activity
 * Contains the major elements of the game
 */
class GameActivity : Activity {

    World world; ///The world present in this game
    Query query; ///The currently active query
    TileElement selected; ///The currently selected object
    Player[] players; ///The players in the game
    Map map; ///The map component; for easy access
    ButtonMenu buttonMenu; ///The button menu for actions; for easy access

    /**
     * Constructs a new GameActivity
     * Generates a world with 6 continents that is 40x30
     * TODO: make world generation based on json configs
     */
    this(Display container) {
        super(container);
        this.world = new World(6, 30, 40);
        this.players ~= new Player("Test", 0);
        this.map = new Map(container, new iRectangle(0, 16, 1100, 524), this.world);
        this.components ~= this.map;
        this.buttonMenu = new ButtonMenu(container, new iRectangle(0, 540, 690, 60));
        this.components ~= this.buttonMenu;
        this.buttonMenu.configuration[0] = new SettleAction(container, this.buttonMenu);
        this.buttonMenu.updateButtonTextures();
        this.world[4][7].city = new City(this.players[0], new Coordinate(4, 7), this.world, 8);
        this.map.selectedElement = this.world[4][7].city;
        this.components ~= new QueryIndicator(container, this);
    }

    /**
     * Sets the query to null if it is fulfilled
     */
    override void draw() {
        if(this.query !is null) {
            if(this.query.isFulfilled) {
                this.query = null;
            }
        }
    }

    /** 
     * Asks the contained query for input from the user
     */
    override void handleEvent(SDL_Event event) {
        if(this.query !is null) {
            this.query.ask(event);
        }
    }

}