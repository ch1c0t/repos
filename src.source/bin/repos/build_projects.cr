def build_projects
  puts "\nStarting to build projects..."
  Workspace.new.process
  puts "\n🎉 Workspace execution complete!"
end
