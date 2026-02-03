param(
  [string]$EnvironmentUrl = "https://orgfe8637fb.crm11.dynamics.com",
  [string]$SolutionFolder = ".\\src\\Solution",
  [string]$ZipPath = ".\\artifacts\\sit_solution_unmanaged.zip"
)

# Pack and import the solution (unmanaged)
New-Item -ItemType Directory -Force -Path .\\artifacts | Out-Null

pac solution pack --zipfile $ZipPath --folder $SolutionFolder --packagetype Unmanaged
pac solution import --environment $EnvironmentUrl --path $ZipPath --publish-changes
