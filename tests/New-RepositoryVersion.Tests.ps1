Describe 'New-RepositoryVersion' {
    Context 'DefaultBehavior' {
        BeforeEach {
            Mock -ModuleName ConventionalVersioning gh { return '{"tagName": "1.2.3"}' }
            Mock -ModuleName ConventionalCommits ConvertTo-ConventionalCommitHeader {
                return @{
                    Type        = 'fix'
                    Scope       = 'scope'
                    Modifier    = '!'
                    Description = 'description'
                }
            }
        }
        
        It 'Should parse a loose message' -ForEach @(
            @{ Commit = 'custom(scope)!: description' ; Version = '2.0.0' }
            @{ Commit = 'custom(scope): description' ; Version = '1.2.4' }
        ) {
            $actual = New-RepositoryVersion -RepositoryName 'x' -CommitMessage $Commit
            $actual | Should -Be $Version
        }
        
        It 'Should fail an additional modifier' {
            { New-RepositoryVersion -RepositoryName 'x' -CommitMessage 'custom(scope)+: description' } | Should -Throw
        }
    }
}