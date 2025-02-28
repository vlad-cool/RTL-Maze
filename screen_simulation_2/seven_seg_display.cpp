#include "seven_seg_display.hpp"

Segment::Segment() : shape(0) {}

Segment::Segment(sf::Vector2f origin, sf::Vector2f size) : shape(6)
{
    bool rotate = false;
    if(size.x > size.y)
    {
        size = sf::Vector2f(size.y, size.x);
        rotate = true;
    }

    float halfWidth = size.x * 0.5f;
    float halfHeight = size.y * 0.5f;
    shape.setOrigin(sf::Vector2f(0, 0));
    shape.setPoint(0, sf::Vector2f(0, halfHeight));
    shape.setPoint(1, sf::Vector2f(halfWidth, halfHeight - halfWidth));
    shape.setPoint(2, sf::Vector2f(halfWidth, -halfHeight + halfWidth));
    shape.setPoint(3, sf::Vector2f(0, -halfHeight));
    shape.setPoint(4, sf::Vector2f(-halfWidth, -halfHeight + halfWidth));
    shape.setPoint(5, sf::Vector2f(-halfWidth, halfHeight - halfWidth));
    shape.setPosition(origin);

    if(rotate)
        shape.setRotation(90);

    setEnable(false);
}

void Segment::draw(sf::RenderWindow& window) const
{
    window.draw(shape);
}

static sf::Color scale(sf::Color color, float value)
{
    sf::Uint8 r = static_cast<sf::Uint8>(color.r * value);
    sf::Uint8 g = static_cast<sf::Uint8>(color.g * value);
    sf::Uint8 b = static_cast<sf::Uint8>(color.b * value);
    return sf::Color(r, g, b, color.a);
}

void Segment::setEnable(bool enable)
{
    float t = enable ? 1 : SSD_DARKENING;
    shape.setFillColor(scale(SSD_MAIN_COLOR, t));
    shape.setOutlineColor(scale(SSD_OUTLINE_COLOR, t));
    shape.setOutlineThickness(SSD_OUTLINE_THICKNESS);
}

SevenSegmentDisplay::SevenSegmentDisplay(sf::Vector2f origin, sf::Vector2f size)
{
    float x_size = size.x * 0.2f;
    float y_size = (size.y - x_size)  * 0.5f;
    float y_pos = (size.y - x_size) * 0.25f;
    float x_pos = (size.x - x_size) * 0.5f;
    segments[0] = Segment(origin + sf::Vector2f(0, -y_size), sf::Vector2f(size.x - x_size, x_size));
    segments[1] = Segment(origin + sf::Vector2f(x_pos, -y_pos), sf::Vector2f(x_size, y_size));
    segments[2] = Segment(origin + sf::Vector2f(x_pos, y_pos), sf::Vector2f(x_size, y_size));
    segments[3] = Segment(origin + sf::Vector2f(0, y_size), sf::Vector2f(size.x - x_size, x_size));
    segments[4] = Segment(origin + sf::Vector2f(-x_pos, y_pos), sf::Vector2f(x_size, y_size));
    segments[5] = Segment(origin + sf::Vector2f(-x_pos, -y_pos), sf::Vector2f(x_size, y_size));
    segments[6] = Segment(origin, sf::Vector2f(size.x - x_size, x_size));
}

void SevenSegmentDisplay::draw(sf::RenderWindow& window) const
{
    for(auto &segment : segments)
        segment.draw(window);
}
    
void SevenSegmentDisplay::setValue(uint8_t value)
{
    for(int i = 0; i < 7; i++)
        segments[i].setEnable(value & (0x1 << i));
}
