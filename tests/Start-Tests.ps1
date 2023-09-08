[CmdletBinding()]
param ()

$RootPath = Convert-Path $PSScriptRoot/..
$ModulePath = Convert-Path $RootPath/ConventionalVersioning

Import-Module -Force Pester
Import-Module -Force PSScriptAnalyzer
Import-Module -Force $ModulePath

Test-ModuleManifest $ModulePath/ConventionalVersioning.psd1
Invoke-ScriptAnalyzer -Recurse -Severity Warning $ModulePath

$configuration = [PesterConfiguration]@{
  Run          = @{
    Path = "$RootPath/tests/"
  }
  CodeCoverage = @{
    Enabled    = $true
    Path       = "$ModulePath/ConventionalVersioning.psm1"
    OutputPath = "$RootPath/coverage.xml"
  }
  TestResult   = @{
    Enabled    = $true
    OutputPath = "$RootPath/output.xml"
  }
}

Invoke-Pester -Configuration $configuration