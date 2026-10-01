def self.detect?(path : Path) : Bool
  File.exists?(path / "shard.yml")
end

def build : Bool
  puts "💎 Identified as a Crystal project using 'shards build'"
  if run_cmd("shards", ["build"])
    puts "✅ Build successful"
    true
  else
    puts "❌ 'shards build' failed"
    false
  end
end
