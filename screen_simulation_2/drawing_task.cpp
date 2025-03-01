#include "drawing_task.hpp"

#define INIT_ERROR std::runtime_error("Bad drawing task initialization.")

TFTByte::TFTByte() : TFTByte(0, 0) {}

TFTByte::TFTByte(bool dc, sf::Uint8 byte) : dc(dc), byte(byte) {}

std::ostream& operator<<(std::ostream& os, const TFTByte& value)
{
    os << "(byte = " << (uint16_t)value.byte << ", dc = " << value.dc << ")";
    return os;
}

DrawingTask::DrawingTask(sf::RenderWindow *window, int max_width, int max_height) :
    window(window), max_width(max_width), max_height(max_height)
{
    pixels = new sf::Uint8[4 * max_width * max_height];
    if(pixels == nullptr)
        throw std::runtime_error("Can't allocate memory for pixels array.");
}

bool DrawingTask::isFinished() 
{ 
    return (screen_ptr == 4 * rect.width * rect.height) && (init_ptr == 11); 
}

void DrawingTask::reset()
{
    if(screen_ptr > 0)
        draw();
    init_ptr = 0; 
    screen_ptr = 0;
}

void DrawingTask::prepare()
{
    int x_min = (static_cast<int>(init_list[1]) << 8) + init_list[2];
    int x_max = (static_cast<int>(init_list[3]) << 8) + init_list[4];
    int y_min = (static_cast<int>(init_list[6]) << 8) + init_list[7];
    int y_max = (static_cast<int>(init_list[8]) << 8) + init_list[9];

    if (x_max < x_min)
    {
        std::swap(x_max, x_min);
    }
    if (y_max < y_min)
    {
        std::swap(y_max, y_min);
    }

    rect = sf::Rect<int>(x_min, y_min, std::max(x_max - x_min + 1, 1), std::max(y_max - y_min + 1, 1));
    if(rect.width > max_width)
        throw std::runtime_error("Incorrect drawing rect width.");
    if(rect.height > max_height)
        throw std::runtime_error("Incorrect drawing rect height.");
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
        screen_ptr = 0;

    if(init_ptr < 11)
    {
        switch (init_ptr)
        {
        case 0:
            if(value.dc == DC_DATA || value.byte != 0x2a)
                throw INIT_ERROR;
            break;
        case 5:
            if(value.dc == DC_DATA || value.byte != 0x2b)
                throw INIT_ERROR;
            break;
        case 10:
            if(value.dc == DC_DATA || value.byte != 0x2c)
                throw INIT_ERROR;
            prepare();
            break;
        default:
            if(value.dc == DC_COMMAND)
                throw INIT_ERROR;
            init_list[init_ptr] = value.byte;
            break;
        }

        init_ptr++;
        return;
    }

    if(value.dc == DC_COMMAND)
        throw std::runtime_error("Color byte with wrong dc(dc == COMMAND) bit.");
    pixels[screen_ptr] = value.byte;
    screen_ptr++;
    if(screen_ptr % 4 == 3) // alpha channel
    {
        pixels[screen_ptr] = 255;
        screen_ptr++;
    }

    if(isFinished() || (screen_ptr % (4 * PIXELS_PER_DRAW) == 0))
        draw();
}
