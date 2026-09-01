private def link_executables
  bin_dir = @path / "bin"
  return unless Dir.exists?(bin_dir)

  Dir.children(bin_dir).each do |executable|
    source_file = bin_dir / executable
    
    next unless File.file?(source_file)
    next unless File::Info.executable?(source_file)

    link_path = @target_bin_dir / executable

    if File.exists?(link_path) || File.symlink?(link_path)
      File.delete(link_path)
    end

    puts "🔗 Linking: #{link_path} -> bin/#{executable}"
    File.symlink(source_file, link_path)
  end
end
