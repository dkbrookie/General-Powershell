Function Get-DHCPScopes{
    $Scopes = Get-DHCPServerv4Scope
    $AllScopes = @{}
    Foreach ($obj in $scopes){
        $Options = Get-DhcpServerv4OptionValue -ComputerName "$env:computername" -ScopeId "$($obj.scopeid)"
        $DNSservers = ($options | Where-Object {$_.optionid -eq 6} | Select-Object -ExpandProperty Value) -join ', '
        $Router = ($options | Where-Object {$_.optionid -eq 3} | Select-Object -ExpandProperty Value)
        $ExclusionRanges = (Get-DhcpServerv4ExclusionRange -ScopeId $obj.scopeid| %{"$($_.StartRange)" + '-' + "$($_.EndRange)" + ', '})
        $NonStandardOptions = @{} 
        $options | Where-Object {$_.optionid -notin (15,51,6,3)} | %{
            $Op = @{}
            $name = "$($_.name)";
            $Value = "$($_.value)";
            $OpId = "$($_.OptionID)";
            $op.add('OptionId',$OpId)
            $op.add('Value',$Value)
            $NonStandardOptions.add($name,$op)
        }
        $Failover = Get-DhcpServerv4Failover -ScopeId $obj.scopeid
        #$FailoverMode = $Failover | Select-Object -ExpandProperty mode
        if ($Failover){
            $pattern = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$"
            if ($failover.partnerserver -match $pattern){
            $ComputerIPAddress = $Failover.PartnerServer
            $PartnerServer = ([System.Net.Dns]::GetHostEntry($ComputerIPAddress).HostName).split('.')[0]
            }
            else{
                $domain = (Get-WmiObject Win32_ComputerSystem).Domain
                $PartnerServer = ("$($Failover.PartnerServer)").replace(".$domain",'')
            }
            $Failover = $True
            $PartnerServer = "$PartnerServer"
            $FailoverMode = Get-DhcpServerv4Failover -ScopeId $obj.scopeid | Select-Object -ExpandProperty mode
        }else{
            $Failover = $False
            $PartnerServer = $Null
            $FailoverMode = $Null
        }
        $ScopeInfo = @{}
        $ScopeInfo.add('ScopeName',"$($obj.name)")
        $ScopeInfo.add('ScopeID',"$($Obj.ScopeID)")
        $ScopeInfo.add('StartRange',"$($obj.startrange)")
        $ScopeInfo.add('EndRange',"$($obj.endrange)")
        $ScopeInfo.add('Subnetmask',"$($obj.subnetmask)")
        $ScopeInfo.add('DNSServers',"$DnsServers")
        $ScopeInfo.add('DefaultGateway',"$Router")
        $ScopeInfo.add('ScopeState',"$($obj.State)")
        $ScopeInfo.add('LeaseDuration',"$($obj.LeaseDuration)")
        $ScopeInfo.add('ExclusionRanges',"$ExclusionRanges")
        $ScopeInfo.add('DHCPOptions',$NonStandardOptions)
        $ScopeInfo.add('DHCPFailover',"$Failover")
        $ScopeInfo.add('PartnerServer',"$PartnerServer")
        $ScopeInfo.add('FailoverMode',"$FailoverMode")
        $AllScopes.add("$($Obj.ScopeID)",$scopeinfo)
        }
        $AllScopes
    }