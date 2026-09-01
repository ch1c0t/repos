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
