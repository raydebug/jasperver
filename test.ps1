# Paths to the files containing the version numbers
$jasperReportsFile = "C:\Path\To\jasperreports_versions.txt"
$poiFile = "C:\Path\To\poi_versions.txt"

# Read the version numbers from the files into arrays
$jasperVersions = Get-Content $jasperReportsFile
$poiVersions = Get-Content $poiFile

# Define paths for the pom template and the actual pom.xml used by Maven
$templatePath = ".\pom_template.xml"
$pomPath = ".\pom.xml"

# Define the HTML file for output
$htmlFile = Join-Path $PSScriptRoot "jasperreports_test_results.html"

# Start HTML Document
$htmlContent = @"
<html>
<head>
    <title>Test Results for JasperReports and Apache POI Versions</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #dddddd; text-align: left; padding: 8px; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>Test Results for JasperReports and Apache POI Versions</h1>
    <table>
        <tr>
            <th>JasperReports Version</th>
            <th>Apache POI Version</th>
            <th>Build Status</th>
            <th>Test Result</th>
        </tr>
"@
foreach ($poiVersion in $poiVersions) {
    foreach ($jasperVersion in $jasperVersions) {
        Write-Host "Testing JasperReports version: $jasperVersion with Apache POI version: $poiVersion"

        # Replace version placeholders in the pom.xml template
        $pomContent = Get-Content $templatePath -Raw
        $pomContent = $pomContent -replace '\$\{jasper.version\}', $jasperVersion
        $pomContent = $pomContent -replace '\$\{poi.version\}', $poiVersion
        $pomContent | Set-Content $pomPath

        # Define paths for the log files using the script directory
        $buildOutputFile = Join-Path $PSScriptRoot "mvn_build_output.log"
        $buildErrorFile = Join-Path $PSScriptRoot "mvn_build_error.log"
        $combinedBuildLogFile = Join-Path $PSScriptRoot "mvn_build_combined.log"

        # Run Maven build and capture the output and errors separately
        $buildOutput = Start-Process -FilePath "mvn" -ArgumentList "clean install" -NoNewWindow -Wait -PassThru -RedirectStandardOutput $buildOutputFile -RedirectStandardError $buildErrorFile

        # Combine output and error logs
        Get-Content $buildOutputFile, $buildErrorFile | Set-Content $combinedBuildLogFile

        $buildStatus = if ($buildOutput.ExitCode -eq 0) { "Success" } else { "Failed" }

        # Capture and filter build and test error details for lines starting with [ERROR]
        $errorDetails = Select-String -Path $combinedBuildLogFile -Pattern "^\[ERROR\]" -AllMatches | ForEach-Object { $_.Line }

        $testResult = if ($buildOutput.ExitCode -eq 0) {
            "Passed"
        } else {
            "Build Failed - " + ($errorDetails -join "<br>")
        }

        # Add row to HTML table
        $htmlContent += @"
            <tr>
                <td>$jasperVersion</td>
                <td>$poiVersion</td>
                <td>$buildStatus</td>
                <td>${testResult}</td>
            </tr>
"@
    }
}

# Close HTML Document
$htmlContent += @"
    </table>
</body>
</html>
"@

# Write HTML content to file
$htmlContent | Out-File -FilePath $htmlFile -Encoding UTF8

Write-Host "All tests completed. HTML results saved to $htmlFile"
