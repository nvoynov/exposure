# rakelib/site.rake
require 'fileutils'
# rakelib/site.rake
require 'fileutils'


namespace :site do
  desc "Launch the local Jekyll preview server with correct paths"
  task :serve do
    puts "Launching local preview for Nikolay Voynov. Exposure..."
    cmd = "bundle exec jekyll serve --source site --destination site/_site --host 0.0.0.0 --force_polling --baseurl \"\""
    system(cmd)
  end

  desc "Clean all temporary build artifacts, caches, and optimized images"
  task :clean do
    puts "Cleaning up build artifacts and media caches for web-exposure..."
    
    # 1. Paths to clean inside the project tree
    artifacts = [
      "site/_site",          # Compiled static website
      "site/.jekyll-cache",  # Jekyll internal compiler cache
      "site/.sass-cache",    # Sass style compiler cache
      "site/_series/*",      # Generated markdown series entries
      "site/assets/gallery/*" # ALL optimized WebP images (full and thumbs)
    ]
    
    # 2. Safely expand wildcards and remove directories/files
    artifacts.each do |pattern|
      Dir.glob(pattern).each do |path|
        if File.directory?(path)
          FileUtils.rm_rf(path)
          puts "  [Cleaned] Directory removed: #{path}"
        elsif File.exist?(path)
          File.delete(path)
          puts "  [Cleaned] File removed: #{path}"
        end
      end
    end
    
    puts "Cleanup complete! Repository source tree is pure."
  end

  desc "Build the production layout and automatically deploy it to GitHub Pages"
  task :deploy do
    puts "Starting clean production build for Nikolay Voynov. Exposure..."
    
    # 1. Clean previous build artifacts safely
    FileUtils.rm_rf("site/_site")
    
    # 2. Extract repository origin URL dynamically from local git metadata
    git_remote = `git remote get-url origin`.strip rescue ""
    if git_remote.empty?
      abort "Error: Could not find any git remote 'origin'. Please ensure your project is linked to a GitHub repository first."
    end

    # 3. Compile the static site strictly under production environment specs
    # This activates Google Analytics and validates live domain structures
    puts "  [Jekyll] Compiling final static assets..."
    success = system("JEKYLL_ENV=production bundle exec jekyll build --source site --destination site/_site")
    abort "Error: Jekyll compilation pipeline failed." unless success

    # 4. Navigate into the output artifacts folder to isolate publishing
    Dir.chdir("site/_site") do
      puts "  [Git] Deploying static bundle directly to GitHub Pages branch..."
      
      # Initialize an ephemeral local git state inside the output tree
      system("git init")
      system("git add .")
      
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      system("git commit -m 'Automated engine deployment: #{timestamp}'")
      
      # Link to the extracted repository origin pointer
      system("git remote add origin #{git_remote}")
      
      # Force push the compiled branch content straight into the deployment stream
      # This completely separates your clean Ruby code from raw build metadata
      system("git push -f origin main:gh-pages")
    end

    puts "\nDeployment stream completed successfully! Your website is live."
  end
end

