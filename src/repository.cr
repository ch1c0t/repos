class Repository
  def initialize(@url : String, @dest_path : String)
  end
  
  def sync
    if Dir.exists?(@dest_path)
      update
    else
      clone
    end
  end
  
  private def clone
    puts "📥 Cloning #{@url} into #{@dest_path}..."
    execute_git(["clone", @url, @dest_path])
  end
  
  private def update
    puts "🔄 Updating repository in #{@dest_path}..."
    execute_git(["pull"], chdir: @dest_path)
  end
  
  private def execute_git(args : Array(String), chdir : String? = nil)
    status = Process.run("git", args, chdir: chdir, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    if status.success?
      puts "✅ Success"
    else
      puts "❌ Failed"
    end
  end
end