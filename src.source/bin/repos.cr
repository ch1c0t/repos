require "yaml"

require "../config"
require "../repository"

begin
  puts "📖 Reading configuration from: #{Config.yaml_file}"
  puts "🚀 Target root directory: #{Config.target_root}"

  tree_config = TreeConfig.from_yaml(File.read(Config.yaml_file))
  sync_tree(tree_config, Config.target_root)

  puts "🎉 Tree reconstruction and updates complete!"
rescue e : Exception
  STDERR.puts "An error occurred: #{e.message}"
  exit 1
end
