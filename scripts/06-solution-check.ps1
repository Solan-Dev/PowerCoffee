param(
  [string]$EnvironmentUrl = "https://orgfe8637fb.crm11.dynamics.com",
  [string]$SolutionFolder = ".\\src\\Solution"
)

# Run solution checker against the solution project
pac solution check --environment $EnvironmentUrl --path $SolutionFolder
