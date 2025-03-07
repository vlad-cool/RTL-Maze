#include "seven_seg_display.hpp"
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

    SevenSegmentDisplay hex4({35, 60}, {50, 100});
    SevenSegmentDisplay hex3({95, 60}, {50, 100});
    SevenSegmentDisplay hex2({155, 60}, {50, 100});
    SevenSegmentDisplay hex1({215, 60}, {50, 100});
    sf::Clock clock;

    sf::RenderWindow window(sf::VideoMode(WIDTH, HEIGHT), "RTL-Maze sim 2");
    sf::RenderWindow score_window(sf::VideoMode(250, 120), "RTL-Maze score");
    DrawingTask drawer(&window, WIDTH, HEIGHT);
    while(window.isOpen() && score_window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }
        while (score_window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                score_window.close();
        }

        if(clock.getElapsedTime().asSeconds() > 1)
        {
            hex1.setValue(~top->hex_disp_1);
            hex2.setValue(~top->hex_disp_2);
            hex3.setValue(~top->hex_disp_3);
            hex4.setValue(~top->hex_disp_4);

            score_window.clear();
            hex1.draw(score_window);
            hex2.draw(score_window);
            hex3.draw(score_window);
            hex4.draw(score_window);
            score_window.display();
            clock.restart();
        }

        top->button_1 = !sf::Keyboard::isKeyPressed(sf::Keyboard::D);
        top->button_2 = !sf::Keyboard::isKeyPressed(sf::Keyboard::S);
        top->button_3 = !sf::Keyboard::isKeyPressed(sf::Keyboard::A);
        top->button_4 = !sf::Keyboard::isKeyPressed(sf::Keyboard::W);

        for(int i = 0; i < BYTES_PER_LOOP; i++)
        {
            TFTByte tft_byte = read_byte(top);
            if((tft_byte.dc == DC_COMMAND) && (tft_byte.byte == 0x2a))
                drawer.reset();
            try
            {
                drawer.handleByte(tft_byte);
            }
            catch(std::runtime_error &e)
            {
                std::cout << e.what() << " Wrong byte " << tft_byte << std::endl;
            }
        }
    }
}
