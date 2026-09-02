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
