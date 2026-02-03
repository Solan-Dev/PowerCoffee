param(
  [string]$PublisherName = "SolanIT",
  [string]$PublisherPrefix = "pc",
  [string]$OutputDirectory = ".\\src\\Solution"
)

# Initializes a Dataverse solution project
pac solution init --publisher-name $PublisherName --publisher-prefix $PublisherPrefix --outputDirectory $OutputDirectory
