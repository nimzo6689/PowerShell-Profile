$scriptPath = $MyInvocation.MyCommand.Path
$invokedScripts = Join-Path (Split-Path $scriptPath -Parent) "scripts"

gci $invokedScripts -Include *.ps1 -Recurse -Force | % {&($_.FullName)}

#Override
function Prompt() {
    (Split-Path $pwd -Qualifier) + "~" + (Split-Path $pwd -Leaf) + "> "
}