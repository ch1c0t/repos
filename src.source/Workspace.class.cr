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
