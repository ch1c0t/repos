extend self

# 1. Define private backing variables
private def self.default_config_path : String
  home_dir = Path.home.to_s
  File.join(home_dir, ".config", "repos", "tree.yml")
end

# 2. Compute the safe values once at compilation/load time
@@yaml_file : String = begin
  path = ENV.fetch("REPOS_CONFIG_TREE") { default_config_path }

  unless File.exists?(path)
    STDERR.puts "Error: Configuration file not found at '#{path}'"
    exit 1
  end

  path
end

@@target_root : String = begin
  root = ENV.fetch("REPOS_ROOT", ".")
  File.expand_path(root)
end

@@tree : TreeConfig = TreeConfig.from_yaml(File.read(@@yaml_file))

# 3. Expose clean public getter methods
def yaml_file : String
  @@yaml_file
end

def target_root : String
  @@target_root
end

def tree
  @@tree
end
