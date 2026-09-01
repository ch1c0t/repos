# Checks if the binaries inside bin/ are newer than the latest git commit
private def up_to_date? : Bool
  bin_dir = @path / "bin"
  return false unless Dir.exists?(bin_dir)

  # Get all actual executable files in the bin directory
  executables = Dir.children(bin_dir).map { |f| bin_dir / f }.select { |f| File.file?(f) && File::Info.executable?(f) }
  return false if executables.empty?

  # Find the oldest executable timestamp in the bin directory
  oldest_bin_time = executables.map { |f| File.info(f).modification_time.to_unix }.min

  # Fetch the timestamp of the last git commit
  last_commit_time = get_last_commit_timestamp
  return false if last_commit_time.nil?

  # If the oldest binary is newer than (or equal to) the last commit, it is up to date
  oldest_bin_time >= last_commit_time
end

private def get_last_commit_timestamp : Int64?
  # Ensure it's a git repo first
  return nil unless Dir.exists?(@path / ".git")

  stdout = IO::Memory.new
  status = Process.run(
    "git", ["log", "-1", "--format=%ct"], 
    chdir: @path.to_s, 
    output: stdout, 
    error: Process::Redirect::Close
  )

  if status.success?
    stdout.to_s.strip.to_i64?
  else
    nil
  end
end
