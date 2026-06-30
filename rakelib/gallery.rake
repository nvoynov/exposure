require_relative '../lib/exposure'

namespace :gallery do
  desc "Optimize master photo archives into WebP sheets via Clean Architecture"
  task :import do
    # Print the official centralized application ASCII banner context
    puts Exposure::BANNER
    puts "========================================================"
    puts "  Starting Exposure Object Pipeline Synchronization...  "
    puts "========================================================"

    # 1. Initialize configuration profile with interactive setup wizard fallback
    config = Exposure::Config.read
    if config.gallery_path.to_s.empty?
      puts "\n[Setup Wizard] Local configuration file 'local_config.yml' not found."
      print "Please enter the absolute path to your source photos folder: "
      
      input_path = $stdin.gets.chomp
      if input_path.empty?
        raise "Initialization aborted: Source photos path cannot be empty!"
      end

      # Secure singleton mutation update executing internal save sequence
      Exposure::Config.update_gallery_path(input_path)
      puts "[Setup Wizard] Configuration successfully locked and saved.\n\n"
    end

    # 2. Spin up concrete infrastructure adapters and lock them into the registry
    puts "[Infrastructure] Initializing system I/O tool adapters..."
    
    # Updated: renamed metadata_port slot to exif_metadata
    container = Struct.new(:exif_metadata, :image_transformation).new(
      Exposure::Adapters::ExifToolAdapter.new,
      Exposure::Adapters::ImageMagickAdapter.new
    )
    
    # Freeze the infrastructure layer globally at boot time
    Exposure::Ports::Context.setup(container)

    # 3. Trigger the final production site compile pipeline orchestrator cleanly
    puts "[Pipeline] Generating fluid WebP prints and site asset trees..."
    
    # Decoupled use-case instantiation resolved seamlessly through the base port
    site_compiler = Exposure::Task::BuildSite.new
    site_compiler.call("site")

    puts "========================================================"
    puts "  Synchronization complete! Pipeline state is actual.   "
    puts "========================================================"
  end
end
