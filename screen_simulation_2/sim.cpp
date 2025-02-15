#include <SFML/Graphics.hpp>
#include "obj_dir/VMaze.h"
#include <iostream>
#include <string>

#define WIDTH 320
#define HEIGHT 480

int main()
{
    sf::RenderWindow window(sf::VideoMode(WIDTH, HEIGHT), "RTL-Maze sim 2");

    while(window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }
    }
}