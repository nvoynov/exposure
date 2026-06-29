% PRESETS

# watermark.png

    # Шаг 1: Конвертируем новый SVG в прозрачный PNG строго в размере 64x64px
    rsvg-convert -w 64 -h 64 watermark.svg -o temp_logo.png

    # Шаг 2: Запекаем его по центру чёрного квадрата 84x84px
    magick -size 84x84 canvas:black temp_logo.png -gravity center -composite photography/compiled-watermark.png
    
    # Шаг 3: Удаляем временный файл
    rm temp_logo.png

