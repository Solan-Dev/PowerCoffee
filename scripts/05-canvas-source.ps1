param(
  [string]$EnvironmentUrl = "https://orgfe8637fb.crm11.dynamics.com",
  [string]$AppName = "PowerCoffee Tasting Notes",
  [string]$AppFile = ".\\artifacts\\PowerCoffee_TastingNotes.msapp",
  [string]$SourceFolder = ".\\src\\Canvas"
)

# Download and unpack a canvas app for source control
New-Item -ItemType Directory -Force -Path .\\artifacts | Out-Null
New-Item -ItemType Directory -Force -Path $SourceFolder | Out-Null

pac canvas download --environment $EnvironmentUrl --name $AppName --file-name $AppFile --overwrite
pac canvas unpack --msapp $AppFile --sources $SourceFolder
