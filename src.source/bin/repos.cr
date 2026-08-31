require "yaml"

require "../config"
require "../repository"

begin
  puts "📖 Reading configuration from: #{Config.yaml_file}"
  puts "🚀 Target root directory: #{Config.target_root}"

  case ARGV.size
  when 0
    sync
    build
  when 1
    case ARGV[0]
    when "sync"
      sync
    when "build"
      build
    end
  end
rescue e : Exception
  STDERR.puts "An error occurred: #{e.message}"
  exit 1
end
