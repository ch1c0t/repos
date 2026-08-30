require "./repos/*"

VERSION = "0.0.0"

case ARGV.size
when 1
  case ARGV[0]
  when "-v", "version", "--version"
    puts VERSION
    exit
  when "-h", "help", "--help"
    print_help
    exit
  end
end

# Top-level mapping representing the Git Provider level (e.g., {"github" => { ... }})
# It maps platform names to the User/Profile level mapping.
alias TreeConfig = Hash(String, ProfileMapping)

# Represents the User level mapping (e.g., {"ch1c0t" => { ... }})
# It maps usernames to their specific repositories.
alias ProfileMapping = Hash(String, RepositoryMapping)

# Represents the Repository level mapping (e.g., {"hobby-rpc" => nil})
# The repositories are keys, and their values are Nil in your configuration format.
alias RepositoryMapping = Hash(String, Nil)


def sync_tree(config : TreeConfig, target_root : String)
  config.each do |platform, profiles|
    profiles.each do |username, repositories|
      
      # Build profile target directory
      profile_path = File.join(target_root, platform, username)
      Dir.mkdir_p(profile_path)
      puts "📁 Profile directory: #{profile_path}"

      repositories.each_key do |repo_name|
        repo_url = "https://#{platform}.com/#{username}/#{repo_name}"
        dest_path = File.join(profile_path, repo_name)
        
        Repository.new(repo_url, dest_path).sync
      end

    end
  end
end

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
