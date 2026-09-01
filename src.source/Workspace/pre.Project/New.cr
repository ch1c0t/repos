getter path : Path
getter name : String
getter target_bin_dir : Path

def initialize(@path : Path, @target_bin_dir : Path)
  @name = @path.basename
end
