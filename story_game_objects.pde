/*********************************************************************************************/
/*********************************************************************************************/
/************************** in this window you can find the objects **************************/
/*********************************************************************************************/
/*********************************************************************************************/




PImage bg ;
int level = 1;

//make the hero object:
Hero hero_1 = new Hero();
Rect player_hand = new Rect();
Door door = new Door();

Gun[] bad_gans; 
//make an object to the sword of the player:
Sword player_sword = new Sword();

//make the bot object:
Bad_gang bad_gang = new Bad_gang();

//make an object to the sword of the bot:
Sword bot_sword = new Sword();

Gun gun_hero = new Gun();

//make an object to use te main functions of the game:
Main_functions main_functions = new Main_functions();

Line sword_line_right = new Line();
Line sword_line_left = new Line();
