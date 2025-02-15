#ifndef DRAW_TASK
#define DRAW_TASK

#include <SFML/Graphics.hpp>

#define PIXELS_PER_DRAW 1280

struct TFTByte
{
    bool dc; // 1 - data, 0 - command
    sf::Uint8 byte;

    TFTByte();
    TFTByte(bool dc, sf::Uint8 byte);
};

std::ostream& operator<<(std::ostream& os, const TFTByte& value);

class DrawingTask
{
private:
    sf::RenderWindow *window;
    sf::Rect<int> rect;
    sf::Uint8 init_list[11];
    sf::Uint8* pixels;
    int init_ptr;
    int scr_ptr;

private:
    void prepare();
    void draw();

public:
    DrawingTask(sf::RenderWindow *window);
    void reset();
    void handleByte(TFTByte value);
    bool isFinished();
};

#endif //DRAW_TASK
