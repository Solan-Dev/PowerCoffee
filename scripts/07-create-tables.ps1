param(
  [string]$EnvironmentUrl = "https://orgfe8637fb.crm11.dynamics.com/",
  [string]$SolutionUniqueName = "PowerCoffee"
)

$ErrorActionPreference = "Stop"

function Ensure-AzModule {
  if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    Write-Host "Az.Accounts not found. Installing for current user..."
    Install-Module Az.Accounts -Scope CurrentUser -Force
  }
}

function Connect-Dataverse {
  param(
    [Parameter(Mandatory)]
    [string]$Url
  )

  Ensure-AzModule

  if ($null -eq (Get-AzTenant -ErrorAction SilentlyContinue)) {
    Connect-AzAccount | Out-Null
  }

  $secureToken = (Get-AzAccessToken -ResourceUrl $Url -AsSecureString).Token
  $token = [System.Net.NetworkCredential]::new('', $secureToken).Password

  $global:baseHeaders = @{
    Authorization    = "Bearer $token"
    Accept           = "application/json"
    "OData-MaxVersion" = "4.0"
    "OData-Version"    = "4.0"
    "MSCRM.SolutionUniqueName" = $SolutionUniqueName
  }

  $global:baseUri = $Url.TrimEnd("/") + "/api/data/v9.2/"
}

function Invoke-DataverseRequest {
  param(
    [Parameter(Mandatory)]
    [string]$Method,
    [Parameter(Mandatory)]
    [string]$Uri,
    [hashtable]$Body
  )

  $headers = $baseHeaders.Clone()
  if ($Body) {
    $headers["Content-Type"] = "application/json; charset=utf-8"
  }

  $request = @{
    Method  = $Method
    Uri     = $Uri
    Headers = $headers
  }
  if ($Body) {
    $request.Body = (ConvertTo-Json $Body -Depth 12)
  }

  Invoke-RestMethod @request | Out-Null
  return $null
}

function Test-EntityExists {
  param(
    [Parameter(Mandatory)]
    [string]$LogicalName
  )

  try {
    Invoke-RestMethod -Method Get -Uri ($baseUri + "EntityDefinitions(LogicalName='$LogicalName')") -Headers $baseHeaders | Out-Null
    return $true
  }
  catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
      return $false
    }
    throw
  }
}

function Test-AttributeExists {
  param(
    [Parameter(Mandatory)]
    [string]$TableLogicalName,
    [Parameter(Mandatory)]
    [string]$AttributeLogicalName
  )

  try {
    Invoke-RestMethod -Method Get -Uri ($baseUri + "EntityDefinitions(LogicalName='$TableLogicalName')/Attributes(LogicalName='$AttributeLogicalName')") -Headers $baseHeaders | Out-Null
    return $true
  }
  catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
      return $false
    }
    throw
  }
}

function New-Table {
  param(
    [Parameter(Mandatory)]
    [string]$SchemaName,
    [Parameter(Mandatory)]
    [string]$DisplayName,
    [Parameter(Mandatory)]
    [string]$DisplayCollectionName,
    [Parameter(Mandatory)]
    [string]$PrimaryNameSchema,
    [Parameter(Mandatory)]
    [string]$PrimaryNameDisplay
  )

  $logicalName = $SchemaName.ToLower()
  if (Test-EntityExists -LogicalName $logicalName) {
    Write-Host "Table $logicalName already exists. Skipping."
    return
  }

  $entity = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.EntityMetadata"
    SchemaName = $SchemaName
    DisplayName = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    DisplayCollectionName = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayCollectionName; LanguageCode = 1033 }) }
    Description = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = "PowerCoffee data"; LanguageCode = 1033 }) }
    OwnershipType = "UserOwned"
    IsActivity = $false
    HasActivities = $false
    HasNotes = $true
    Attributes = @(
      @{
        "@odata.type" = "Microsoft.Dynamics.CRM.StringAttributeMetadata"
        SchemaName = $PrimaryNameSchema
        DisplayName = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $PrimaryNameDisplay; LanguageCode = 1033 }) }
        Description = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = "Primary name"; LanguageCode = 1033 }) }
        RequiredLevel = @{ Value = "None" }
        IsPrimaryName = $true
        MaxLength = 100
        FormatName = @{ Value = "Text" }
      }
    )
  }

  Write-Host "Creating table $SchemaName..."
  Invoke-DataverseRequest -Method Post -Uri ($baseUri + "EntityDefinitions") -Body $entity | Out-Null
}

function New-StringColumn {
  param(
    [string]$TableLogicalName,
    [string]$SchemaName,
    [string]$DisplayName,
    [int]$MaxLength = 200
  )

  $logicalName = $SchemaName.ToLower()
  if (Test-AttributeExists -TableLogicalName $TableLogicalName -AttributeLogicalName $logicalName) {
    Write-Host "Column $logicalName already exists on $TableLogicalName. Skipping."
    return
  }

  $body = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.StringAttributeMetadata"
    SchemaName = $SchemaName
    DisplayName = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    Description = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    RequiredLevel = @{ Value = "None" }
    MaxLength = $MaxLength
    FormatName = @{ Value = "Text" }
  }

  Invoke-DataverseRequest -Method Post -Uri ($baseUri + "EntityDefinitions(LogicalName='$TableLogicalName')/Attributes") -Body $body | Out-Null
}

function New-MemoColumn {
  param(
    [string]$TableLogicalName,
    [string]$SchemaName,
    [string]$DisplayName,
    [int]$MaxLength = 4000
  )

  $logicalName = $SchemaName.ToLower()
  if (Test-AttributeExists -TableLogicalName $TableLogicalName -AttributeLogicalName $logicalName) {
    Write-Host "Column $logicalName already exists on $TableLogicalName. Skipping."
    return
  }

  $body = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.MemoAttributeMetadata"
    SchemaName = $SchemaName
    DisplayName = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    Description = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    RequiredLevel = @{ Value = "None" }
    Format = "Text"
    MaxLength = $MaxLength
  }

  Invoke-DataverseRequest -Method Post -Uri ($baseUri + "EntityDefinitions(LogicalName='$TableLogicalName')/Attributes") -Body $body | Out-Null
}

function New-IntegerColumn {
  param(
    [string]$TableLogicalName,
    [string]$SchemaName,
    [string]$DisplayName,
    [int]$Min = 0,
    [int]$Max = 100
  )

  $logicalName = $SchemaName.ToLower()
  if (Test-AttributeExists -TableLogicalName $TableLogicalName -AttributeLogicalName $logicalName) {
    Write-Host "Column $logicalName already exists on $TableLogicalName. Skipping."
    return
  }

  $body = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.IntegerAttributeMetadata"
    SchemaName = $SchemaName
    DisplayName = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    Description = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    RequiredLevel = @{ Value = "None" }
    MinValue = $Min
    MaxValue = $Max
  }

  Invoke-DataverseRequest -Method Post -Uri ($baseUri + "EntityDefinitions(LogicalName='$TableLogicalName')/Attributes") -Body $body | Out-Null
}

function New-DateColumn {
  param(
    [string]$TableLogicalName,
    [string]$SchemaName,
    [string]$DisplayName
  )

  $logicalName = $SchemaName.ToLower()
  if (Test-AttributeExists -TableLogicalName $TableLogicalName -AttributeLogicalName $logicalName) {
    Write-Host "Column $logicalName already exists on $TableLogicalName. Skipping."
    return
  }

  $body = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.DateTimeAttributeMetadata"
    SchemaName = $SchemaName
    DisplayName = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    Description = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    RequiredLevel = @{ Value = "None" }
    Format = "DateOnly"
  }

  Invoke-DataverseRequest -Method Post -Uri ($baseUri + "EntityDefinitions(LogicalName='$TableLogicalName')/Attributes") -Body $body | Out-Null
}

function New-ChoiceColumn {
  param(
    [string]$TableLogicalName,
    [string]$SchemaName,
    [string]$DisplayName,
    [string[]]$Options
  )

  $logicalName = $SchemaName.ToLower()
  if (Test-AttributeExists -TableLogicalName $TableLogicalName -AttributeLogicalName $logicalName) {
    Write-Host "Column $logicalName already exists on $TableLogicalName. Skipping."
    return
  }

  $optionValue = 100000000
  $optionSet = @{
    IsGlobal = $false
    OptionSetType = "Picklist"
    Options = @()
  }

  foreach ($opt in $Options) {
    $optionSet.Options += @{
      Value = $optionValue
      Label = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $opt; LanguageCode = 1033 }) }
    }
    $optionValue++
  }

  $body = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.PicklistAttributeMetadata"
    SchemaName = $SchemaName
    DisplayName = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    Description = @{ "@odata.type" = "Microsoft.Dynamics.CRM.Label"; LocalizedLabels = @(@{ "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"; Label = $DisplayName; LanguageCode = 1033 }) }
    RequiredLevel = @{ Value = "None" }
    OptionSet = $optionSet
  }

  Invoke-DataverseRequest -Method Post -Uri ($baseUri + "EntityDefinitions(LogicalName='$TableLogicalName')/Attributes") -Body $body | Out-Null
}

function New-LookupColumn {
  param(
    [string]$TableLogicalName,
    [string]$SchemaName,
    [string]$DisplayName,
    [string[]]$Targets
  )

  $logicalName = $SchemaName.ToLower()
  if (Test-AttributeExists -TableLogicalName $TableLogicalName -AttributeLogicalName $logicalName) {
    Write-Host "Column $logicalName already exists on $TableLogicalName. Skipping."
    return
  }

  Write-Host "Lookup columns require relationship creation via Web API actions. Skipping $SchemaName."
  return
}

Connect-Dataverse -Url $EnvironmentUrl

# Create tables
New-Table -SchemaName "pc_TastingNote" -DisplayName "Tasting Note" -DisplayCollectionName "Tasting Notes" -PrimaryNameSchema "pc_Name" -PrimaryNameDisplay "Note Name"
New-Table -SchemaName "pc_Roastery" -DisplayName "Roastery" -DisplayCollectionName "Roasteries" -PrimaryNameSchema "pc_Name" -PrimaryNameDisplay "Roastery Name"

# Columns for Tasting Note
New-StringColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_CoffeeName" -DisplayName "Coffee Name" -MaxLength 200
New-StringColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_Roaster" -DisplayName "Roaster" -MaxLength 200
New-ChoiceColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_Origin" -DisplayName "Origin" -Options @("Ethiopia","Colombia","Kenya","Brazil","Other")
New-ChoiceColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_Process" -DisplayName "Process" -Options @("Washed","Natural","Honey","Experimental")
New-ChoiceColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_RoastLevel" -DisplayName "Roast Level" -Options @("Light","Medium","Dark")
New-ChoiceColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_BrewMethod" -DisplayName "Brew Method" -Options @("Pour-over","Espresso","AeroPress","French Press","Other")
New-IntegerColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_Rating" -DisplayName "Rating" -Min 1 -Max 10
New-MemoColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_TastingNotes" -DisplayName "Tasting Notes"
New-DateColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_BrewDate" -DisplayName "Brew Date"
New-LookupColumn -TableLogicalName "pc_tastingnote" -SchemaName "pc_BrewedBy" -DisplayName "Brewed By" -Targets @("systemuser")

# Columns for Roastery
New-StringColumn -TableLogicalName "pc_roastery" -SchemaName "pc_Website" -DisplayName "Website" -MaxLength 300
New-StringColumn -TableLogicalName "pc_roastery" -SchemaName "pc_Location" -DisplayName "Location" -MaxLength 200

Write-Host "Done."