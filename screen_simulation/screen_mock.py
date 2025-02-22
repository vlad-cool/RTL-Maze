# by Aleksandr

import pygame
import subprocess
import numpy as np
import threading

WIDTH, HEIGHT = 320, 480

pixels = []
process = subprocess.Popen(["vvp", "tsm.icv"], text=True, stdout=subprocess.PIPE)
initialization_counter = 42

pixels_lock = threading.Lock()

def read_pixels_from_pipe():
    global pixels
    global process
    global initialization_counter
    try:
        buffer = process.stdout.readlines(320)
        for line in buffer:
            if (initialization_counter > 0) and not line.startswith("rst"):
                initialization_counter -= 1
                continue
            if line.startswith("rst"):
                pixels = []
                continue
            if line.startswith("1"):
                parts = line.split(" ")
                if len(parts) < 2:
                    continue
                try:
                    pixel = int(parts[1], 16)
                    if (len(pixels) == 0) or (len(pixels[-1]) == 3):
                        pixels.append([pixel])
                    else:
                        pixels[-1].append(pixel)
                except ValueError:
                    print(f"Error parsing pixel value: <{parts[1]}>")
    except Exception as e:
        print(f"Error reading from pipe: {e}")
    return pixels

def read_pixels_thread():
    global pixels
    while True:
        new_pixels = read_pixels_from_pipe()
        with pixels_lock:
            pixels = new_pixels

def draw_pixels_on_screen(screen, pixels):
    for y in range(HEIGHT):
        for x in range(WIDTH):
            if (len(pixels) > (WIDTH*y + x)) and (len(pixels[WIDTH*y+x]) == 3):
                screen.set_at((x, y), pixels[(WIDTH*y+x)])
            else:
                break

def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Screen Mock")
    clock = pygame.time.Clock()
    screen.fill((0, 0, 0))
    reader_thread = threading.Thread(target=read_pixels_thread, daemon=True)
    reader_thread.start()
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
        with pixels_lock:
            draw_pixels_on_screen(screen, pixels)
        pygame.display.flip()
        clock.tick(60)
    pygame.quit()

if __name__ == "__main__":
    main()
