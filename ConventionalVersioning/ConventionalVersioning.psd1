@{
    Author          = 'Arwyn'
    CompanyName     = 'www.gsri.team'
    Copyright       = '(c) 2023 - ArwynFr - MIT license'

    ModuleVersion   = '0.1.0'
    GUID            = 'ec9051d3-085e-424e-b261-c52631e82bb7'
    Description     = 'A powerhsell module dedicated to publishing GitHub releases based on conventional commits'
    HelpInfoURI       = 'https://github.com/ArwynFr/pwsh-ConventionalVersioning#readme'
    
    PrivateData       = @{
        ProjectUri = 'https://github.com/ArwynFr/pwsh-ConventionalVersioning'
        LicenseUri = 'https://github.com/ArwynFr/pwsh-ConventionalVersioning/blob/main/LICENSE'
    }

    RootModule      = 'ConventionalVersioning.psm1'
    FunctionsToExport = @(
        'New-RepositoryVersion'
        'New-GitHubRelease'
    )
}