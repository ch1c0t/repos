# Top-level mapping representing the Git Provider level (e.g., {"github" => { ... }})
# It maps platform names to the User/Profile level mapping.
alias TreeConfig = Hash(String, ProfileMapping)

# Represents the User level mapping (e.g., {"ch1c0t" => { ... }})
# It maps usernames to their specific repositories.
alias ProfileMapping = Hash(String, RepositoryMapping)

# Represents the Repository level mapping (e.g., {"hobby-rpc" => nil})
# The repositories are keys, and their values are Nil in your configuration format.
alias RepositoryMapping = Hash(String, Nil)
