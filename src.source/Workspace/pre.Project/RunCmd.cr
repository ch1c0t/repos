protected def run_cmd(command : String, args : Array(String)) : Bool
  status = Process.run(
    command, 
    args, 
    chdir: @path.to_s, 
    output: Process::Redirect::Inherit, 
    error: Process::Redirect::Inherit
  )
  status.success?
end
