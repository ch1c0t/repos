require "yaml"
require "../repository"

begin
  home_dir = Path.home.to_s
  default_config_path = File.join(home_dir, ".config", "repos", "tree.yml")

  yaml_file = ENV.fetch("REPOS_CONFIG_TREE") { default_config_path }
  yaml_file = default_config_path if yaml_file.empty?

  unless File.exists?(yaml_file)
    STDERR.puts "Error: Configuration file not found at '#{yaml_file}'"
    exit 1
  end

  target_root = ENV.fetch("REPOS_ROOT", ".")
  target_root = "." if target_root.empty?
  target_root = File.expand_path(target_root)

  puts "📖 Reading configuration from: #{yaml_file}"
  puts "🚀 Target root directory: #{target_root}"

  config = TreeConfig.from_yaml(File.read(yaml_file))
  sync_tree(config, target_root)

  puts "🎉 Tree reconstruction and updates complete!"
rescue e : Exception
  STDERR.puts "An error occurred: #{e.message}"
  exit 1
end
