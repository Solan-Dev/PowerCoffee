param(
  [string]$EnvironmentUrl = "https://orgfe8637fb.crm11.dynamics.com"
)

# Opens the Maker portal for the environment
pac tool maker --environment $EnvironmentUrl
