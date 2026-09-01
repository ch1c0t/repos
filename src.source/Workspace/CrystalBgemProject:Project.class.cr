def self.detect?(path : Path) : Bool
  File.exists?(path / "shard.yml") && File.exists?(path / "Gemfile")
end

def build : Bool
  puts "💎 Identified as a Crystal project using Bgem"
  puts "🛠️  Running bundle install..."
  unless run_cmd("bundle", ["install"])
    puts "❌ 'bundle install' failed"
    return false
  end

  puts "🛠️  Running bundle exec rake..."
  if run_cmd("bundle", ["exec", "rake"])
    puts "✅ Build successful"
    true
  else
    puts "❌ 'bundle exec rake' failed"
    false
  end
end
