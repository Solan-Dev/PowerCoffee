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

function Test-RelationshipExists {
  param(
    [Parameter(Mandatory)]
    [string]$SchemaName
  )

  $filter = [uri]::EscapeDataString("SchemaName eq '$SchemaName'")
  $uri = $baseUri + "RelationshipDefinitions?`$select=SchemaName&`$filter=$filter"
  $result = Invoke-RestMethod -Method Get -Uri $uri -Headers $baseHeaders
  return ($result.value.Count -gt 0)
}

function New-OneToManyRelationship {
  param(
    [string]$SchemaName,
    [string]$ReferencedEntity,
    [string]$ReferencingEntity,
    [string]$LookupSchemaName,
    [string]$LookupDisplayName
  )

  if (Test-RelationshipExists -SchemaName $SchemaName) {
    Write-Host "Relationship $SchemaName already exists. Skipping."
    return
  }

  $relationship = @{
    "@odata.type" = "Microsoft.Dynamics.CRM.OneToManyRelationshipMetadata"
    SchemaName = $SchemaName
    ReferencedEntity = $ReferencedEntity
    ReferencingEntity = $ReferencingEntity
    AssociatedMenuConfiguration = @{
      Behavior = "UseCollectionName"
      Group = "Details"
      Label = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.Label"
        LocalizedLabels = @(@{
          "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
          Label = $LookupDisplayName
          LanguageCode = 1033
        })
      }
      Order = 10000
    }
    CascadeConfiguration = @{
      Assign = "Cascade"
      Delete = "RemoveLink"
      Merge = "Cascade"
      Reparent = "Cascade"
      Share = "Cascade"
      Unshare = "Cascade"
      RollupView = "NoCascade"
    }
    Lookup = @{
      "@odata.type" = "Microsoft.Dynamics.CRM.LookupAttributeMetadata"
      SchemaName = $LookupSchemaName
      DisplayName = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.Label"
        LocalizedLabels = @(@{
          "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
          Label = $LookupDisplayName
          LanguageCode = 1033
        })
      }
      Description = @{
        "@odata.type" = "Microsoft.Dynamics.CRM.Label"
        LocalizedLabels = @(@{
          "@odata.type" = "Microsoft.Dynamics.CRM.LocalizedLabel"
          Label = $LookupDisplayName
          LanguageCode = 1033
        })
      }
      RequiredLevel = @{ Value = "None" }
    }
  }

  Write-Host "Creating relationship $SchemaName (lookup $LookupSchemaName)..."
  $headers = $baseHeaders.Clone()
  $headers["Content-Type"] = "application/json; charset=utf-8"
  Invoke-RestMethod -Method Post -Uri ($baseUri + "RelationshipDefinitions") -Headers $headers -Body (ConvertTo-Json $relationship -Depth 12) | Out-Null
}

Connect-Dataverse -Url $EnvironmentUrl

# Create lookup relationship: pc_TastingNote (many) -> systemuser (one)
New-OneToManyRelationship `
  -SchemaName "pc_TastingNote_SystemUser" `
  -ReferencedEntity "systemuser" `
  -ReferencingEntity "pc_tastingnote" `
  -LookupSchemaName "pc_BrewedBy" `
  -LookupDisplayName "Brewed By"

Write-Host "Done."