function Create-Channel {   
    param (   
        $ChannelName, $GroupId
    )   
    Process {
        try {
            New-TeamChannel -GroupId $GroupId -DisplayName $ChannelName
        }
        Catch {
        }
    }
}

function Add-Users {   
    param(   
        $Users, $GroupId, $CurrentUsername, $Role
    )   
    Process {
        
        try {
            $teamusers = $Users -split ";" 
            if ($teamusers) {
                for ($j = 0; $j -le ($teamusers.count - 1) ; $j++) {
                    if ($teamusers[$j] -ne $CurrentUsername) {
                        Add-TeamUser -GroupId $GroupId -User $teamusers[$j] -Role $Role
                    }
                }
            }
        }
        Catch {
        }
    }
}

function Create-NewTeam {   
    param (   
        $ImportPath
    )   
    Process {
        Import-Module MicrosoftTeams
        $cred = Get-Credential
        $username = $cred.UserName
        Connect-MicrosoftTeams -Credential $cred

        $teams = Import-Csv -Path $ImportPath

        foreach ($team in $teams) {

            $TeamsName = $team.TeamName

            Write-Host "Start creating the team: " $TeamsName

            $group = New-Team  -displayname "$TeamsName" -Visibility "private"

            Write-Host "Creating channels..."
            Create-Channel -ChannelName $team.ChannelName -GroupId $group.GroupId

            Write-Host "Adding team members..."
            Add-Users -Users $team.Members -GroupId $group.GroupId -CurrentUsername $username  -Role Member 

            Write-Host "Adding team owners..."
            Add-Users -Users $team.Owners -GroupId $group.GroupId -CurrentUsername $username  -Role Owner

            Write-Host "Completed creating the team: " $TeamsName
            $team = $null
        }
    }
}

Create-NewTeam -ImportPath ".\data.csv"