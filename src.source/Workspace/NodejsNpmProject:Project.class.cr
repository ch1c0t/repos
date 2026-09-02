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
