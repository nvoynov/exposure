require_relative 'test_helper'

# Configuration setup block
search_path = "site/_site/assets/gallery/**/full/*.webp" # Adjust this glob path to match your actual test images layout
watermark_path = "site/og-watermark.svg"                   # Leveraging favicon path for quick standalone testing execution
output_destination = "og-main-preview.jpg"

puts "Scanning folder for available source image frames..."
image_pool = Dir.glob(search_path).select { it.match?(/\.(jpg|jpeg|png|webp)$/i) }

pp image_pool.take(5)

if image_pool.size < 5
  puts "Error: Found only #{image_pool.size} images in '#{search_path}'. Need at least 5 to construct the mosaic!"
  exit 1
end

# Select exactly 5 unique random images from the harvested pool
selected_samples = image_pool.sample(5)

puts "Selected files for 'Todd Hido' exhibition wall generation:"
selected_samples.each { puts " -> #{it}" }

begin
  adapter = Exposure::Adapters::ImageMagickAdapter.new
  
  puts "\nRunning ImageMagick execution matrix streams..."
  adapter.make_mosaic(
    sources: selected_samples,
    destination: output_destination,
    watermark: watermark_path
  )
  
  puts "Success! Core preview asset materialized directly at: ./#{output_destination}"
rescue => e
  puts "Pipeline execution failed: #{e.message}"
end

