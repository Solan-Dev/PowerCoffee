param(
  [string]$EnvironmentUrl = "https://orgfe8637fb.crm11.dynamics.com",
  [string]$ProfileName = "SolanIT-Dev"
)

# Create or update the auth profile (interactive browser login)
pac auth create --name $ProfileName --url $EnvironmentUrl

# Select the profile and environment
pac auth select --name $ProfileName
pac env select --url $EnvironmentUrl

# Show current context
pac auth who
pac env who
