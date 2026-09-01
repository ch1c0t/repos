require "yaml"

require "../config"
require "../repository"
require "../workspace"

begin
  puts "📖 Reading configuration from: #{Config.yaml_file}"
  puts "🚀 Target root directory: #{Config.target_root}"

  case ARGV.size
  when 0
    sync_tree
    build_projects
  when 1
    case ARGV[0]
    when "sync"
      sync_tree
    when "build"
      build_projects
    end
  end
rescue e : Exception
  STDERR.puts "An error occurred: #{e.message}"
  exit 1
end
