require 'gosu'

TILES_PER_WINDOW_WIDTH = 80
TILES_PER_WINDOW_HEIGHT = 64

def image_to_map_file(image_file_name, output_file_name)
  
  win = Gosu::Window.new(1,1,false)
  image = Gosu::Image.new(win, image_file_name, false)
  tile_width = image.width / TILES_PER_WINDOW_WIDTH
  tile_height = image.height / TILES_PER_WINDOW_HEIGHT
  
  tiles = Gosu::Image.load_tiles(win, image_file_name, tile_width, tile_height, false)
  
  result_array = Array.new(TILES_PER_WINDOW_HEIGHT) { Array.new(TILES_PER_WINDOW_WIDTH) {0} }
  
  TILES_PER_WINDOW_HEIGHT.times do |row|
    TILES_PER_WINDOW_WIDTH.times do |col|
      tile_num = TILES_PER_WINDOW_WIDTH * row + col
      result_array[row][col] = tile_to_can_traverse(tiles[tile_num])
    end
  end
  
  File.open(output_file_name, 'w') do |f|
    f.write(Marshal::dump(result_array))
  end
end

def tile_to_can_traverse(image)
  # if there is any white in the tile, we consider it traversable
  good = "\xFF\xFF\xFF\xFF".force_encoding("ASCII-8BIT")
  blob = image.to_blob
  return blob.index(good) ? 1 : 0
end

if ARGV.count != 2
  puts "Expected 2 arguments, input image file and output file (will be overwritten if it exists)"
  exit
end
image_to_map_file(ARGV[0], ARGV[1])