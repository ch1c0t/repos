require "file_utils"

class Workspace
  getter bin_target_dir : Path
  
  def initialize
    home = Path.home
    @bin_target_dir = home / ".local" / "bin"
  end
  
  def process
    Dir.mkdir_p(@bin_target_dir)
  
    Config.each_project_path do |path|
      next unless File.directory?(path)
  
      if project = Project.create(path, @bin_target_dir)
        project.process
      else
        puts "\n🔎 Checking project at #{path}"
        puts "skip Unknown project structure"
      end
    end
  end

  class Project
    module AbstractBuild
      def build : Bool
        false
      end
    end
  
    module AbstractDetect
      def detect?(path : Path) : Bool
        false
      end
    end
  
    module LinkExecutables
      private def link_executables
        bin_dir = @path / "bin"
        return unless Dir.exists?(bin_dir)
      
        Dir.children(bin_dir).each do |executable|
          source_file = bin_dir / executable
          
          next unless File.file?(source_file)
          next unless File::Info.executable?(source_file)
      
          link_path = @target_bin_dir / executable
      
          if File.exists?(link_path) || File.symlink?(link_path)
            File.delete(link_path)
          end
      
          puts "🔗 Linking: #{link_path} -> bin/#{executable}"
          File.symlink(source_file, link_path)
        end
      end
    end
  
    module New
      getter path : Path
      getter name : String
      getter target_bin_dir : Path
      
      def initialize(@path : Path, @target_bin_dir : Path)
        @name = @path.basename
      end
    end
  
    module RunCmd
      protected def run_cmd(command : String, args : Array(String)) : Bool
        status = Process.run(
          command, 
          args, 
          chdir: @path.to_s, 
          output: Process::Redirect::Inherit, 
          error: Process::Redirect::Inherit
        )
        status.success?
      end
    end
  
    module UpToDate
      # Checks if the binaries inside bin/ are newer than the latest git commit
      def up_to_date? : Bool
        bin_dir = @path / "bin"
        return false unless Dir.exists?(bin_dir)
      
        # Get all actual executable files in the bin directory
        executables = Dir.children(bin_dir).map { |f| bin_dir / f }.select { |f| File.file?(f) && File::Info.executable?(f) }
        return false if executables.empty?
      
        # Find the oldest executable timestamp in the bin directory
        oldest_bin_time = executables.map { |f| File.info(f).modification_time.to_unix }.min
      
        # Fetch the timestamp of the last git commit
        last_commit_time = get_last_commit_timestamp
        return false if last_commit_time.nil?
      
        # If the oldest binary is newer than (or equal to) the last commit, it is up to date
        oldest_bin_time >= last_commit_time
      end
      
      private def get_last_commit_timestamp : Int64?
        # Ensure it's a git repo first
        return nil unless Dir.exists?(@path / ".git")
      
        stdout = IO::Memory.new
        status = Process.run(
          "git", ["log", "-1", "--format=%ct"], 
          chdir: @path.to_s, 
          output: stdout, 
          error: Process::Redirect::Close
        )
      
        if status.success?
          stdout.to_s.strip.to_i64?
        else
          nil
        end
      end
    end
  
    include New
    
    SUBCLASSES = [] of Project.class
    
    macro inherited
      Project::SUBCLASSES << self
    end
    
    def self.create(path : Path, target_bin_dir : Path) : Project?
      SUBCLASSES.each do |subclass|
        return subclass.new(path, target_bin_dir) if subclass.detect?(path)
      end
      nil
    end
    
    extend AbstractDetect
    include AbstractBuild
    
    include RunCmd
    include UpToDate
    include LinkExecutables
    
    def process
      puts "\n🔎 Checking project: #{@name} (#{self.class.name})"
    
      if up_to_date?
        puts "⏭️  Binaries are newer than the last git commit. Skipping build."
        link_executables # Ensure symlinks exist even if skipped
        return
      end
    
      if build
        link_executables
      end
    end
  end

  class CrystalBgemProject < Project
    def self.detect?(path : Path) : Bool
      File.exists?(path / "shard.yml") && File.exists?(path / "Gemfile")
    end
    
    def build : Bool
      puts "💎 Identified as a Crystal project using Bgem"
      puts "🛠️  Running bundle install..."
      unless run_cmd("bundle", ["install"])
        puts "❌ 'bundle install' failed"
        return false
      end
    
      puts "🛠️  Running bundle exec rake..."
      if run_cmd("bundle", ["exec", "rake"])
        puts "✅ Build successful"
        true
      else
        puts "❌ 'bundle exec rake' failed"
        false
      end
    end
  end

  class NodejsNpmProject < Project
    # Identifies a Node.js project by checking for a package.json file
    def self.detect?(path : Path) : Bool
      File.exists?(path / "package.json")
    end
    
    # Build logic for running npm install operations
    def build : Bool
      puts "🟢 Identified as a Node.js project using npm (package.json present)"
      
      puts "🛠️  Running npm install..."
      unless run_cmd("npm", ["install"])
        puts "❌ 'npm install' failed"
        return false
      end
    
      puts "🛠️  Running npm install --global ...."
      if run_cmd("npm", ["install", "--global", "."])
        puts "✅ Global npm installation successful"
        true
      else
        puts "❌ 'npm install --global .' failed"
        false
      end
    end
    
    # Overrides the base class timestamp logic specifically for Node.js workflows
    def up_to_date? : Bool
      node_modules = @path / "node_modules"
      lock_file = @path / "package-lock.json"
    
      # Find a valid reference target to check (prefer node_modules, fall back to lockfile)
      target_path = if Dir.exists?(node_modules)
                      node_modules
                    elsif File.exists?(lock_file)
                      lock_file
                    else
                      return false # Neither exists, needs a fresh install
                    end
    
      # Get the modification time of our chosen Node target
      node_target_time = File.info(target_path).modification_time.to_unix
    
      last_commit_time = get_last_commit_timestamp
      return false if last_commit_time.nil?
    
      # If node_modules or package-lock.json was modified after the last commit, it's up to date
      node_target_time >= last_commit_time
    end
  end
end