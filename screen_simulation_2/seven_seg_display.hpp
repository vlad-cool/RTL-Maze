#ifndef SEVEN_SEG_DISPLAY
#define SEVEN_SEG_DISPLAY

#include <SFML/Graphics.hpp>

#define SSD_MAIN_COLOR sf::Color(0xFF6347FF)
#define SSD_OUTLINE_COLOR sf::Color(0x8B0000FF)
#define SSD_OUTLINE_THICKNESS 3
#define SSD_DARKENING 0.2f

class Segment
{
private:
    sf::ConvexShape shape;

public:
    Segment();
    Segment(sf::Vector2f origin, sf::Vector2f size);
    void draw(sf::RenderWindow& window) const;
    void setEnable(bool enable);
};

class SevenSegmentDisplay
{
private:
    Segment segments[7];

public:
    SevenSegmentDisplay(sf::Vector2f origin, sf::Vector2f size);
    void draw(sf::RenderWindow& window) const;
    void setValue(uint8_t value);
};

#endif //SEVEN_SEG_DISPLAY
