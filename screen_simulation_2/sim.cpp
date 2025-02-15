#include "drawing_task.hpp"
#include "obj_dir/VMaze.h"
#include <iostream>
#include <cstdlib>
#include <string>

#define WIDTH 320
#define HEIGHT 480
#define INIT_SEQUENCE_LENGTH 31 // 32 - 1, except waiting
#define BYTES_PER_LOOP 10

void reset(VMaze *top, int resetTicks)
{
    top->clk = 0;
    top->true_rst = 0;
    std::cout << "Reset Ticks: " << resetTicks << std::endl;
    for(int i = 0; i < resetTicks; i++)
    {
        top->eval();
        top->clk = !top->clk;
        top->eval();
        top->clk = !top->clk;
    }
    top->true_rst = 1;
}

TFTByte read_byte(VMaze *top)
{
    bool dc = 0;
    sf::Uint8 byte = 0;
    int byte_ptr = 7;

    while(byte_ptr >= 0)
    {
        top->clk = !top->clk;
        top->eval();

        // only one per tick
        // ignore CS
        if(!top->tft_clk)
            continue;

        byte += top->tft_mosi << byte_ptr;
        if(byte_ptr == 7)
            dc = top->tft_dc;
        else if(dc != top->tft_dc)
            throw std::runtime_error("Wrong position in bit stream.");
        byte_ptr--;
    }

    return TFTByte(dc, byte);
}

void handle_init_sequence(VMaze *top)
{
    std::cout << std::hex;
    std::cout << "Init sequence:" << std::endl;
    for(int i = 0; i < INIT_SEQUENCE_LENGTH; i++)
        std::cout << read_byte(top) << std::endl;
    std::cout << std::dec;
}

int main()
{
    VMaze *top = new VMaze();
    if(top == nullptr)
        throw std::runtime_error("Something went wrong with memory allocation.");
    srand(time(0));
    reset(top, rand() % 255);
    handle_init_sequence(top);

    sf::RenderWindow window(sf::VideoMode(WIDTH, HEIGHT), "RTL-Maze sim 2");
    DrawingTask drawer(&window);
    while(window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        top->button_1 = sf::Keyboard::isKeyPressed(sf::Keyboard::W);
        top->button_2 = sf::Keyboard::isKeyPressed(sf::Keyboard::S);
        top->button_3 = sf::Keyboard::isKeyPressed(sf::Keyboard::A);
        top->button_4 = sf::Keyboard::isKeyPressed(sf::Keyboard::D);

        for(int i = 0; i < BYTES_PER_LOOP; i++)
        {
            auto b = read_byte(top);
            try
            {
                drawer.handleByte(b);
            }
            catch(std::runtime_error &e)
            {
                //std::cout << "wrong byte " << b << std::endl;
            }
            if(drawer.isFinished())
                drawer.reset();
        }
    }
}
