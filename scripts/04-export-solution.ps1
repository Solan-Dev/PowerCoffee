param(
  [string]$EnvironmentUrl = "https://orgfe8637fb.crm11.dynamics.com",
  [string]$SolutionName = "PowerCoffee",
  [string]$ExportPath = ".\\artifacts\\PowerCoffee.zip",
  [string]$UnpackFolder = ".\\src\\Solution"
)

# Export solution and unpack to source
New-Item -ItemType Directory -Force -Path .\\artifacts | Out-Null

pac solution export --environment $EnvironmentUrl --name $SolutionName --path $ExportPath --overwrite
pac solution unpack --zipfile $ExportPath --folder $UnpackFolder --packagetype Unmanaged --allowDelete true --allowWrite true
