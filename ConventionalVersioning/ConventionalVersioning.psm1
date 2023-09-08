function Get-RepositoryVersion {
    [CmdletBinding()]
    [OutputType([semver])]
    param (
        [Parameter()]
        [string]
        $RepositoryName
    )

    $PrevErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'silentlycontinue'
    $currentVersionNumber = (gh release view --json tagName --repo $RepositoryName | convertfrom-json).TagName
    $currentVersion = [semver]::new($currentVersionNumber)
    $ErrorActionPreference = $PrevErrorActionPreference
    return $currentVersion
}

function Get-VersionBumpType {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $CommitMessage,

        [Parameter()]
        [switch]
        $FeatUpgradesMinor,

        [Parameter()]
        [switch]
        $AllowAdditionalModifiers,
    
        [Parameter()]
        [switch]
        $StrictTypes
    )

    $conventions = $CommitMessage | ConvertTo-ConventionalCommitHeader -StrictTypes:$StrictTypes -AdditionalModifiers:$AllowAdditionalModifiers
    $modifier_bump = '-+!'.IndexOf($conventions.Modifier ?? '-')
    $type_bump = $conventions.Type -eq 'feat' -and $FeatUpgradesMinor ? 1 : 0
    $long_bump = switch ($true) {
    ($CommitMessage -match '\nBREAKING CHANGE: ') { 2 }
    ($CommitMessage -match '\nNEW FEATURE: ') { $AllowAdditionalModifiers ? 1 : 0 }
        default { 0 }
    }

    $bump = (@($modifier_bump, $type_bump, $long_bump) | Measure-Object -Maximum).Maximum
    return @('patch', 'minor', 'major')[$bump]
}

function New-RepositoryVersion {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]
        $RepositoryName,

        [Parameter()]
        [string]
        $CommitMessage,

        [Parameter()]
        [switch]
        $FeatUpgradesMinor,

        [Parameter()]
        [switch]
        $AllowAdditionalModifiers,
    
        [Parameter()]
        [switch]
        $StrictTypes
    )

    Install-Module -Force StepSemVer, ConventionalCommits
    Import-Module -Force StepSemVer, ConventionalCommits

    $parameters = @{
        FeatUpgradesMinor        = $FeatUpgradesMinor
        AllowAdditionalModifiers = $AllowAdditionalModifiers
        CommitMessage            = $CommitMessage
        StrictTypes              = $StrictTypes
    }
    $bumpType = Get-VersionBumpType @parameters
    $currentVersion = Get-RepositoryVersion -RepositoryName "$RepositoryName"
    $nextVersion = $currentVersion | Step-SemVer -BumpType $bumpType

    "current-version=$currentVersion" >> $env:GITHUB_OUTPUT
    "next-version=$nextVersion" >> $env:GITHUB_OUTPUT
    "bump-type=$bumpType" >> $env:GITHUB_OUTPUT

    return $nextVersion
}

function New-GitHubRelease {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]
        $RepositoryName,
    
        [Parameter(Mandatory)]
        [semver]
        $NextVersion,

        [Parameter()]
        [string]
        $Pattern
    )

    if ($PSCmdlet.ShouldProcess($NextVersion, 'gh release create')) {
        gh release create "$NextVersion" --generate-notes --repo "$RepositoryName"
    }

    if (-Not [string]::IsNullOrEmpty($Pattern)) {
        if ($PSCmdlet.ShouldProcess($Pattern, 'gh release upload')) {
            gh release upload "$NextVersion" --repo "$RepositoryName" (Get-Item "$Pattern")
        }
    }

}