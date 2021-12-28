Describe 'Script Tests' {
    It 'passes ScriptAnalyzer' {
        Invoke-ScriptAnalyzer -Path Set-InstallScriptDirectories.ps1 | Should -BeNullOrEmpty
    }

    It 'passes no params' {
        .\Set-InstallScriptDirectories.ps1 | Should -BeNullOrEmpty
    }
}