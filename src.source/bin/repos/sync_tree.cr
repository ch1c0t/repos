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
