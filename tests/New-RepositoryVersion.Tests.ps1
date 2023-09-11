Describe 'New-RepositoryVersion' {
    Context 'ExistingVersion' {
        BeforeEach {
            Mock -ModuleName ConventionalVersioning gh { return '{"tagName": "1.2.3"}' }
        }        
        It 'Should parse a loose message' -ForEach @(
            @{ Commit = 'custom(scope)!: description' ; Version = '2.0.0' }
            @{ Commit = 'custom(scope): description' ; Version = '1.2.4' }
        ) {
            $actual = New-RepositoryVersion -RepositoryName 'x' -CommitMessage $Commit
            $actual | Should -Be $Version
            $LASTEXITCODE | Should -Be 0
        }
    }
    Context 'HasNoRealese' {
        BeforeEach {
            Mock -ModuleName ConventionalVersioning gh {
                $global:LASTEXITCODE = 1
                return $null
            }
        }
        
        It 'Should always return 0.1.0' -ForEach @(
            @{ Commit = 'custom(scope)!: description' ; Version = '0.1.0' }
            @{ Commit = 'custom(scope): description' ; Version = '0.1.0' }
        ) {
            $actual = New-RepositoryVersion -RepositoryName 'x' -CommitMessage $Commit
            $actual | Should -Be $Version
            $LASTEXITCODE | Should -Be 0
        }
    }
}