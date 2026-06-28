require 'tmpdir'
require 'open3'
require_relative '../ports/image_transformation'
require_relative '../config'

module Exposure
  module Adapters

    # Infrastructure adapter executing native ImageMagick CLI conversion streams
    class ImageMagickAdapter < Ports::ImageTransformation

      def initialize
        # Verify if the target binary is installed and executable in the system
        unless system("command -v magick >/dev/null 2>&1")
          raise RuntimeError, "ImageMagick CLI dependency is missing in this OS!"
        end
      end
      
      # @see Exposure::Ports::ImageTransformation#convert_to_full
      def convert_to_full(source:, destination:)
        # SMART CACHE GUARD: Skip optimization if the converted asset is up to date
        if File.exist?(destination) && File.mtime(source) <= File.mtime(destination)
          return true
        end

        config = Exposure::Config.instance
        dimensions = IO.popen(
          ["magick", "identify", "-format", "%w %h", source], "r"
        ) { it.read }
        
        width, height = dimensions.to_s.split.map(&:to_i)
        return false if width.to_i.zero? || height.to_i.zero?

        short_side = [width, height].min
        cmd = ["magick", source]

        if short_side > config.max_short_side
          cmd += ["-resize", "#{config.max_short_side}x#{config.max_short_side}^>"]
        end

        if config.unsharp_enabled && !config.unsharp_spec.empty?
          cmd += ["-unsharp", config.unsharp_spec]
        end

        cmd += ["-quality", "82", destination]
        system(*cmd)
      end

      # @see Exposure::Ports::ImageTransformation#convert_to_thumbnail
      def convert_to_thumbnail(source:, destination:)
        # SMART CACHE GUARD: Skip preview generation if it is already actualized
        if File.exist?(destination) && File.mtime(source) <= File.mtime(destination)
          return true
        end

        cmd = ["magick", source, "-resize", "600x400>", "-quality", "75", destination]
        system(*cmd)
      end


      # @see Exposure::Ports::ImageTransformation#create_exhibition_wall
      def create_exhibition_wall(images:, compiled_wm:, output:)
        raise ArgumentError, 'Requires exactly 5 images' if images.length != 5

        cmd = [
          'magick', '-size', '1200x630', 'canvas:#FFFFFF',
          '(', images[0], '-resize', '400x570^', '-gravity', 'center', '-crop', '400x570+0+0', '+repage', ')', '-gravity', 'northwest', '-geometry', '+30+30', '-composite',
          '(', images[1], '-resize', '450x300^', '-gravity', 'center', '-crop', '450x300+0+0', '+repage', ')', '-gravity', 'northwest', '-geometry', '+460+30', '-composite',
          '(', images[2], '-resize', '240x240^', '-gravity', 'center', '-crop', '240x240+0+0', '+repage', ')', '-gravity', 'northwest', '-geometry', '+460+360', '-composite',
          '(', images[3], '-resize', '220x240^', '-gravity', 'center', '-crop', '220x240+0+0', '+repage', ')', '-gravity', 'northwest', '-geometry', '+720+360', '-composite',
          '(', images[4], '-resize', '472x262^', '-gravity', 'center', '-crop', '472x262+0+0', '+repage', '-bordercolor', 'white', '-border', '4', ')', '-gravity', 'northwest', '-geometry', '+690+50', '-composite',
          
          compiled_wm, '-gravity', 'southeast', '-geometry', '+60+60', '-composite',
          
          # Production payload optimization switches
          '-strip',
          '-sampling-factor', '4:2:0',
          '-interlace', 'Plane',
          '-quality', '82',
          output
        ]

        execute_command(cmd)
      end

      # @see Exposure::Ports::ImageTransformation#create_scattered_portfolo
      def create_scattered_portfolio(images:, compiled_wm:, output:)
        raise ArgumentError, 'Requires exactly 5 images' if images.length != 5

        # layers_config = [
        #   { max_dim: '350x350', rot: -4, border: 6, pos: '+150+100' }, 
        #   { max_dim: '320x320', rot: 5,  border: 6, pos: '+650+80'  }, 
        #   { max_dim: '360x360', rot: -2, border: 6, pos: '+200+300' }, 
        #   { max_dim: '340x340', rot: 3,  border: 6, pos: '+680+190' }, 
        #   { max_dim: '450x450', rot: -1, border: 8, pos: '+380+140' }  
        # ]

        # Refactored: Expanded bounding boxes and adjusted positions 
        # to "paint with broader strokes", eliminating dead whitespace.
        # layers_config = [
        #   { max_dim: '420x420', rot: -5, border: 6, pos: '+60+60' },   # Bottom-left (Moved closer to edge)
        #   { max_dim: '390x390', rot: 6,  border: 6, pos: '+720+50' },  # Bottom-right (Expanded and spread out)
        #   { max_dim: '430x430', rot: -3, border: 7, pos: '+120+240' }, # Mid-left
        #   { max_dim: '410x410', rot: 4,  border: 7, pos: '+740+220' }, # Mid-right
        #   { max_dim: '540x540', rot: -1, border: 9, pos: '+330+60' }   # Main HERO print (Dominant center anchor)
        # ]

        # Recalibrated composition grid:
        # - Move layer 0 (top-left) higher and further left.
        # - Push layers 1 and 3 (right side) inwards to safe margins.
        layers_config = [
          { max_dim: '430x430', rot: -6, border: 6, pos: '+30+20' },   # 0. Top-left (Raised and pushed left)
          { max_dim: '390x390', rot: 5,  border: 6, pos: '+680+60' },  # 1. Top-right (Pulled inwards from edge)
          { max_dim: '430x430', rot: -3, border: 7, pos: '+110+250' }, # 2. Bottom-left
          { max_dim: '410x410', rot: 4,  border: 7, pos: '+690+230' }, # 3. Bottom-right (Pulled inwards from edge)
          { max_dim: '540x540', rot: -1, border: 9, pos: '+320+65' }   # 4. Main Hero print anchor
        ]

        temp_cards = []

        layers_config.each_with_index do |config, idx|
          temp_path = File.join(Dir.tmpdir, "og_scatter_card_#{idx}.png")
          prepare_scattered_card(images[idx], temp_path, config[:max_dim], config[:rot], config[:border])
          temp_cards << temp_path
        end

        cmd = ['magick', '-size', '1200x630', 'canvas:#FAFAFA']
        
        temp_cards.each_with_index do |card_path, idx|
          cmd.concat([card_path, '-geometry', layers_config[idx][:pos], '-composite'])
        end

        cmd.concat([compiled_wm, '-gravity', 'southeast', '-geometry', '+50+50', '-composite'])
        
        # Production payload optimization switches
        cmd.concat([
          '-strip',
          '-sampling-factor', '4:2:0',
          '-interlace', 'Plane',
          '-quality', '82',
          output
        ])

        execute_command(cmd)
      ensure
        temp_cards&.each { File.delete(it) if File.exist?(it) }
      end

      private

      # Simulates a physical photographic card with adaptive bounding box sizing.
      def prepare_scattered_card(source_path, target_path, max_dim, degrees, border_size)
        cmd = [
          'magick', source_path,
          '-resize', max_dim,
          '-bordercolor', 'white',
          '-border', border_size.to_s,
          
          '(', '+clone', '-background', 'rgba(0,0,0,0.15)', '-shadow', '60x4+2+4', ')', 
          '+swap', '-background', 'transparent', '-layers', 'merge',
          
          '-background', 'transparent',
          '-rotate', degrees.to_s,
          '+repage', 
          target_path
        ]
        execute_command(cmd)
      end

      # System execution abstract runner tracking console exit statuses.
      def execute_command(cmd)
        stdout, stderr, status = Open3.capture3(*cmd)
        return if status.success?

        raise "ImageMagick execution failed: #{stderr.strip}"
      end
 
    end
  end
end
