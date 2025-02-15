#include "drawing_task.hpp"

#define DATA 1
#define COMMAND 0
#define INIT_ERROR std::runtime_error("Bad drawing task initialization.")

TFTByte::TFTByte() : TFTByte(0, 0) {}

TFTByte::TFTByte(bool dc, sf::Uint8 byte) : dc(dc), byte(byte) {}

std::ostream& operator<<(std::ostream& os, const TFTByte& value)
{
    os << "(byte = " << (uint16_t)value.byte << ", dc = " << value.dc << ")";
    return os;
}

DrawingTask::DrawingTask(sf::RenderWindow *window) : window(window) {}

bool DrawingTask::isFinished() 
{ 
    return (scr_ptr == 4 * rect.width * rect.height) && (init_ptr == 11); 
}

void DrawingTask::reset()
{
    init_ptr = 0; 
    scr_ptr = 0;
    if(pixels)
    {
        delete[] pixels;
        pixels = nullptr;
    }
}

#include <iostream>

void DrawingTask::prepare()
{
    int x_min = (static_cast<int>(init_list[1]) << 8) + init_list[2];
    int x_max = (static_cast<int>(init_list[3]) << 8) + init_list[4];
    int y_min = (static_cast<int>(init_list[6]) << 8) + init_list[7];
    int y_max = (static_cast<int>(init_list[8]) << 8) + init_list[9];
    rect = sf::Rect<int>(x_min, y_min, x_max - x_min + 1, y_max - y_min + 1);

    if(pixels)
        throw std::runtime_error("Trying to create new array of pixels when old was't deleted yet.");
    pixels = new sf::Uint8[4 * rect.width * rect.height];
    if(pixels == nullptr)
        throw std::runtime_error("Can't allocate memory for pixels array.");
}

void DrawingTask::draw()
{
    sf::Texture texture;
    texture.create(rect.width, rect.height);
    texture.update(pixels);
    sf::Sprite sprite(texture);
    sprite.setPosition(rect.left, rect.top);
    window->draw(sprite);
    window->display();
}

void DrawingTask::handleByte(TFTByte value)
{
    if(isFinished())
        throw std::runtime_error("Sending extra bytes to drawing task.");

    if(init_ptr < 11)
    {
        switch (init_ptr)
        {
        case 0:
            if(value.dc == DATA || value.byte != 0x2a)
                throw INIT_ERROR;
            break;
        case 5:
            if(value.dc == DATA || value.byte != 0x2b)
                throw INIT_ERROR;
            break;
        case 10:
            if(value.dc == DATA || value.byte != 0x2c)
                throw INIT_ERROR;
            prepare();
            break;
        default:
            if(value.dc == COMMAND)
                throw INIT_ERROR;
            init_list[init_ptr] = value.byte;
            break;
        }

        init_ptr++;
        return;
    }

    if(value.dc == COMMAND)
        throw std::runtime_error("Color byte with wrong dc(dc == COMMAND) bit.");
    pixels[scr_ptr] = value.byte;
    scr_ptr++;
    if(scr_ptr % 4 == 3) // alpha channel
    {
        pixels[scr_ptr] = 255;
        scr_ptr++;
    }

    if(isFinished() || (scr_ptr % (4 * PIXELS_PER_DRAW) == 0))
        draw();
}
