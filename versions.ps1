# Function to download version data, filter, and save to a text file
function Save-VersionsToFile($metadataUrl, $outputFile, $startVersion) {
    # Fetch the metadata XML
    [xml]$metadata = Invoke-WebRequest -Uri $metadataUrl -UseBasicParsing

    # Extract and filter version numbers
    $versions = $metadata.metadata.versioning.versions.version |
            Where-Object {
                $_ -match '^\d+\.\d+.*$' -and [version]($_ -replace '-.*', '') -ge [version]$startVersion
            } |
            Sort-Object -Property { [version]($_ -replace '-.*', '') } -Descending

    # Save the filtered versions to a text file
    $versions | Out-File -FilePath $outputFile -Encoding UTF8
}

# Define the Maven metadata URLs for JasperReports and Apache POI
$jasperMetadataUrl = "https://repo1.maven.org/maven2/net/sf/jasperreports/jasperreports/maven-metadata.xml"
$poiMetadataUrl = "https://repo1.maven.org/maven2/org/apache/poi/poi/maven-metadata.xml"

# Paths for the output text files and start versions
$jasperOutputFile = ".\jasperreports_versions.txt"
$poiOutputFile = ".\poi_versions.txt"
$jasperStartVersion = "6.17.0"
$poiStartVersion = "5.0.0"

# Save versions to text files
Save-VersionsToFile -metadataUrl $jasperMetadataUrl -outputFile $jasperOutputFile -startVersion $jasperStartVersion
Save-VersionsToFile -metadataUrl $poiMetadataUrl -outputFile $poiOutputFile -startVersion $poiStartVersion

Write-Host "Versions saved to $jasperOutputFile and $poiOutputFile"
