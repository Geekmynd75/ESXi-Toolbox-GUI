##############################################
# File:			ESXi Toolbox GUI.ps1
# Creation date:	2017.01.28
# Last modifications:	2017.02.12
# Author :		Munna75 - BIC Team
# Project :		UC2 Virtualization
##############################################

################Windows Form Loaded
# region
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
# endregion

#################################################
#           FUNCTIONS
#################################################

# vCenter/ESXi Connect Function
function connectServer{
    try {
    $connect = Connect-VIServer -Server $serverTextBox.Text -User $usernameTextBox.Text -Password $passwordTextBox.Text -WarningAction 0 -ErrorAction Stop
    $buttonConnect.Enabled = $false
    $serverTextBox.Enabled = $false
    $usernameTextBox.Enabled = $false
    $passwordTextBox.Enabled = $false
    $buttonDisconnect.Enabled = $true
            
    getVmHosts #Populate ESXi
    $HostDropDownBox.Enabled = $true
    $licenseTextBox.Enabled = $true
    $buttonViewLicense.Enabled = $true
    $buttonUpdateLicense.Enabled = $true
    $NTPTextBox.Enabled = $true
    $buttonViewNTP.Enabled = $true
    $buttonAddNTP.Enabled = $true
    $buttonRemoveNTP.Enabled = $true

    $ServiceDropDownBox.Enabled=$true
    $buttonGetServices.Enabled = $true
    $buttonViewServices.Enabled = $true
    $enableServiceRadioButton.Enabled = $true
    $disableServiceRadioButton.Enabled = $true
    $buttonApplyESXiOnly.Enabled = $true
    
    $exporttoOutBoxESXi.Enabled = $true
    $exporttoCSVESXi.Enabled = $true
    $exporttoHTMESXi.Enabled = $true
    $buttonExportESXi.Enabled = $true
    $buttonExportNetESXi.Enabled = $true
    $exporttoOutBoxDataStores.Enabled = $true
    $exporttoCSVDataStores.Enabled = $true
    $exporttoHTMDataStores.Enabled = $true
    $buttonExportDataStores.Enabled = $true
    $VmDropDownBox.Enabled = $true
    $buttonGetVMs.Enabled = $true
    $buttonViewVMs.Enabled = $true
    $buttonDetailsVMs.Enabled = $true
    
    $outputTextBox.text = "`nCurrently connected to $($serverTextBox.Text)" #If connection is successfull let user know it  
    }
    catch {
        $outputTextBox.text = "`nSomething went wrong connecting to server - Please type correctly..."
    }
}

# vCenter/ESXi Disconnect Function
function disconnectServer{
    try {
    Disconnect-VIServer -Confirm:$false -Force:$true

    $buttonConnect.Enabled = $true 
    $serverTextBox.Enabled = $true
    $usernameTextBox.Enabled = $true
    $passwordTextBox.Enabled = $true
    $buttonDisconnect.Enabled = $false
    
    $HostDropDownBox.Items.Clear() #Remove all items
    $HostDropDownBox.Enabled=$false
    $licenseTextBox.Clear() #Remove all text
    $licenseTextBox.Enabled = $false
    $buttonViewLicense.Enabled = $false
    $buttonUpdateLicense.Enabled = $false
    $NTPTextBox.Clear() #Remove all text
    $NTPTextBox.Enabled = $false
    $buttonViewNTP.Enabled = $false
    $buttonAddNTP.Enabled = $false
    $buttonRemoveNTP.Enabled = $false
        
    $buttonGetServices.Enabled = $false
    $buttonViewServices.Enabled = $false
    $ServiceDropDownBox.Items.Clear() #Remove all items
    $ServiceDropDownBox.Enabled=$false
    $enableServiceRadioButton.Enabled = $false
    $disableServiceRadioButton.Enabled = $false
    $buttonApplyESXiOnly.Enabled = $false

    $exporttoOutBoxESXi.Enabled = $false
    $exporttoCSVESXi.Enabled = $false
    $exporttoHTMESXi.Enabled = $false
    $buttonExportESXi.Enabled = $false
    $buttonExportNetESXi.Enabled = $false
    $exporttoOutBoxDataStores.Enabled = $false
    $exporttoCSVDataStores.Enabled = $false
    $exporttoHTMDataStores.Enabled = $false
    $buttonExportDataStores.Enabled = $false
    $VmDropDownBox.Items.Clear() #Remove all items
    $VmDropDownBox.Enabled = $false
    $buttonGetVMs.Enabled = $false
    $buttonViewVMs.Enabled = $false
    $buttonDetailsVMs.Enabled = $false
 
    $outputTextBox.text = "`nSuccessfully disconnected from $($serverTextBox.Text)"
    }
    catch {    
    $outputTextBox.text = "`nSomething went wrong disconnecting from server !!"
    }
}

# Get All ESXi/Hosts Function
function getVmHosts{
    try {
    $vmhosts = Get-VMHost | Where-Object {$_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected"} #Returns only powered On VmHosts
        foreach ($vm in $vmhosts) {
            $HostDropDownBox.Items.Add($vm.Name) #Add Hosts to DropDown List
        }    
    }
    catch {  
    $outputTextBox.text = "`nSomething went wrong getting VMHost!!"
    }
}

# View License
function viewLicense{
    try{
        $outputTextBox.text = "`nGetting License Key on ESXi/Host: $($HostDropDownBox.SelectedItem.ToString())"
        $LicenseTextBox.text = Get-VMHost $($HostDropDownBox.SelectedItem.ToString()) | Select-Object -expandproperty LicenseKey
        }
    catch{
        $outputTextBox.text = "`nSomething went wrong getting License on ESXi !!"
    }
}

# Update License
function updateLicense{
    try{
        $License = Set-VMHost -VMHost $($HostDropDownBox.SelectedItem.ToString()) -LicenseKey $licenseTextBox.text  
        $outputTextBox.text = "`nLicense has been updated on ESXi/Host: $($HostDropDownBox.SelectedItem.ToString())"
        }
    catch{
        $outputTextBox.text = "`nSomething went wrong getting License on ESXi !!"
    }
}

# View Server
function viewNTP{
    try{
        $NTPTextBox.text = Get-VMHostNtpServer -VMHost $($HostDropDownBox.SelectedItem.ToString())
        $outputTextBox.text = "`nGetting details of NTP Server on ESXi/Host: $($HostDropDownBox.SelectedItem.ToString())"
        }
    catch{
        $outputTextBox.text = "`nSomething went wrong getting NTP Server on ESXi !!"
    }
}

# Add Server
function addNTP{
    try{
        $NTP = Add-VMHostNtpServer -VMHost $($HostDropDownBox.SelectedItem.ToString()) -NtpServer $NTPTextBox.text
        $outputTextBox.text = "`nNTP Server has been added on ESXi/Host: $($HostDropDownBox.SelectedItem.ToString())"
        }
    catch{
        $outputTextBox.text = "`nSomething went wrong getting NTP Server on ESXi !!"
    }
}

# Remove Server
function removeNTP{
    try{
        $NTP = Remove-VMHostNtpServer -VMHost $($HostDropDownBox.SelectedItem.ToString()) -NtpServer $NTPTextBox.text -Confirm:$false
        $outputTextBox.text = "`nNTP Server has been removed on ESXi/Host: $($HostDropDownBox.SelectedItem.ToString())"
        }
    catch{
        $outputTextBox.text = "`nSomething went wrong getting NTP Server on ESXi !!"
    }
}

# Get All Services on ESXi/Hosts Function
function getServicesOnHost{
    try {
		$outputTextBox.text = "`nGetting Services on ESXi/Host: $($HostDropDownBox.SelectedItem.ToString())"		
		$services = Get-VMHost $($HostDropDownBox.SelectedItem.ToString()) | Get-VMHostService | Where-Object Label
		foreach ($vm in $services) {	
			$ServiceDropDownBox.Items.Add($vm.Label) #Add Services to DropDown List	
		}
		$ServiceDropDownBox.Enabled=$true
        $buttonGetServices.Enabled = $false
    }
    catch { 
    	$outputTextBox.text = "`nSomething went wrong getting Services!!"
    }
}

# Enable/Disable Service Function
function enabledisableService{
    try{
		if($enableServiceRadioButton.Checked -eq $true){
            Get-VMHostService -VMHost $($HostDropDownBox.SelectedItem.ToString()) | Where-Object {$_.Label -eq "$($ServiceDropDownBox.SelectedItem.ToString())"} | Start-VMHostService
            $outputTextBox.text = "`n$($ServiceDropDownBox.SelectedItem.ToString()) service is successfully enabled on $($HostDropDownBox.SelectedItem.ToString())"
		}
        elseif($disableServiceRadioButton.Checked -eq $true){
			Get-VMHostService -VMHost $($HostDropDownBox.SelectedItem.ToString()) | Where-Object {$_.Label -match "$($ServiceDropDownBox.SelectedItem.ToString())"} | Stop-VMHostService -Confirm:$false
            $outputTextBox.text = "`n$($ServiceDropDownBox.SelectedItem.ToString()) service is successfully disabled on $($HostDropDownBox.SelectedItem.ToString())"
		}
    }
    catch{
        $outputTextBox.text = "`nSomething went wrong getting Service on ESXi/Hosts !!"
    }
}

# All Services List Function
function viewServicesOnHost{
    try {
        $outputTextBox.text = "`nGetting All Services on ESXi/Host: $($HostDropDownBox.SelectedItem.ToString())"
        Get-VMHost $($HostDropDownBox.SelectedItem.ToString()) | Get-VMHostService | sort-object -property Label | Out-GridView -Title "All Services Status on $($HostDropDownBox.SelectedItem.ToString())" -Verbose
        }
    catch{
        $outputTextBox.text = "`nSomething went wrong getting All Services!!"
        }
}

# Get Inventory ESXi/Hosts Function
function detailsESXiHosts{
    try{
        if (!($exporttoOutBoxESXi.Checked -eq $true) -and !($exporttoCSVESXi.Checked -eq $true) -and !($exporttoHTMESXi.Checked -eq $true)) {$outputTextBox.text = "`nNo Checkbox selected, please select one"} 
        if ($exporttoOutBoxESXi.Checked -eq $true){
                Get-VMHost | Select-Object NetworkInfo, Name, Model, Version, LicenseKey, ProcessorType, NumCpu, CpuTotalMhz, CpuUsageMhz, MemoryTotalGB, MemoryUsageGB, State, PowerState, Parent, Build | sort-object -property NetworkInfo | Out-Gridview -Title "ESXi/Hosts Inventory" -Verbose
                $outputTextBox.text = "`nFull details of Hosts are been exposed in OutGridView"
        }
        if ($exporttoCSVESXi.Checked -eq $true){
                Get-VMHost | Select-Object NetworkInfo, Name, Model, Version, LicenseKey, ProcessorType, NumCpu, CpuTotalMhz, CpuUsageMhz, MemoryTotalGB, MemoryUsageGB, State, PowerState, Parent, Build | Export-Csv "$dir\ESXiHosts-Details.csv" -NoTypeInformation
                $outputTextBox.text = "Exported Successfully in C:\ESXiHosts-Details.csv"
        }
        if ($exporttoHTMESXi.Checked -eq $true){
                $a = "<style>"
                $a = $a + "BODY{background-color:peachpuff;}"
                $a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: separate;}"
                $a = $a + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:thistle}"
                $a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:PaleGoldenrod;text-align:center;vertical-align:middle;}"
                $a = $a + "</style>"
                Get-VMHost | Select-Object NetworkInfo, Name, Model, Version, LicenseKey, ProcessorType, NumCpu, CpuTotalMhz, CpuUsageMhz, MemoryTotalGB, MemoryUsageGB, State, PowerState, Parent, Build | ConvertTo-HTML -head $a -Title "ESXi/Hosts Inventory" -body "<H2>ESXi/Hosts Inventory</H2>" | Out-File "$dir\ESXiHosts-Details.htm"
                Invoke-Item "$dir\ESXiHosts-Details.htm"
                $outputTextBox.text = "Exported Successfully in C:\ESXiHosts-Details.htm"
        }
        if (($exporttoOutBoxESXi.Checked -eq $true) -and ($exporttoCSVESXi.Checked -eq $true) -and ($exporttoHTMESXi.Checked -eq $true)) {$outputTextBox.text = "`nAll Files are exported at C:\"}
        }
    catch {  
    $outputTextBox.text = "`nSomething went wrong, please select one checkbox"
    }
}

# Get Inventory ESXi/Hosts Function
function detailsNetESXiHosts{
    try{
        if (!($exporttoOutBoxESXi.Checked -eq $true) -and !($exporttoCSVESXi.Checked -eq $true) -and !($exporttoHTMESXi.Checked -eq $true)) {$outputTextBox.text = "`nNo Checkbox selected, please select one"} 
        if ($exporttoOutBoxESXi.Checked -eq $true){
                Get-VMHostNetworkAdapter | select VMhost, Name, IP, SubnetMask, Mac, PortGroupName, vMotionEnabled, mtu, FullDuplex, BitRatePerSec | sort-object -property VMhost | Out-Gridview -Title "ESXi/Hosts Network Inventory" -Verbose
                $outputTextBox.text = "`nNetwork details of Hosts are been exposed in OutGridView"
        }
        if ($exporttoCSVESXi.Checked -eq $true){
                Get-VMHostNetworkAdapter | select VMhost, Name, IP, SubnetMask, Mac, PortGroupName, vMotionEnabled, mtu, FullDuplex, BitRatePerSec | Export-Csv "$dir\ESXiHosts-NetDetails.csv" -NoTypeInformation
                $outputTextBox.text = "Exported Successfully in C:\ESXiHosts-NetDetails.csv"
        }
        if ($exporttoHTMESXi.Checked -eq $true){
                $a = "<style>"
                $a = $a + "BODY{background-color:peachpuff;}"
                $a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: separate;}"
                $a = $a + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:thistle}"
                $a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:PaleGoldenrod;text-align:center;vertical-align:middle;}"
                $a = $a + "</style>"
                Get-VMHostNetworkAdapter | select VMhost, Name, IP, SubnetMask, Mac, PortGroupName, vMotionEnabled, mtu, FullDuplex, BitRatePerSec | ConvertTo-HTML -head $a -Title "ESXi/Hosts Network Inventory" -body "<H2>ESXi/Hosts Network Inventory</H2>" | Out-File "$dir\ESXiHosts-NetDetails.htm"
                Invoke-Item "$dir\ESXiHosts-NetDetails.htm"
                $outputTextBox.text = "Exported Successfully in C:\ESXiHosts-NetDetails.htm"
        }
        if (($exporttoOutBoxESXi.Checked -eq $true) -and ($exporttoCSVESXi.Checked -eq $true) -and ($exporttoHTMESXi.Checked -eq $true)) {$outputTextBox.text = "`nAll Files are exported at C:\"}
        }
    catch {  
    $outputTextBox.text = "`nSomething went wrong, please select one checkbox"
    }
}

# Get Inventory DataStores Function
function detailsDataStores{
    try{
        if (!($exporttoOutBoxDataStores.Checked -eq $true) -and !($exporttoCSVDataStores.Checked -eq $true) -and !($exporttoHTMDataStores.Checked -eq $true)) {$outputTextBox.text = "`nNo Checkbox selected, please select one"} 
        if ($exporttoOutBoxDataStores.Checked -eq $true){
                Get-Datastore | Select-Object Name, Type, FreeSpaceMB, CapacityMB, DatastoreBrowserPath | sort-object -property Name | Out-Gridview -Title "DataStores Inventory" -Verbose
                $outputTextBox.text = "`nFull details of Hosts are been exposed in OutGridView"
        }
        if ($exporttoCSVDataStores.Checked -eq $true){
                Get-Datastore | Select-Object Name, Type, FreeSpaceMB, CapacityMB, DatastoreBrowserPath | Export-Csv "$dir\DataStores-Details.csv" -NoTypeInformation
                $outputTextBox.text = "Exported Successfully in C:\ESXiHosts-Details.csv"
        }
        if ($exporttoHTMDataStores.Checked -eq $true){
                $a = "<style>"
                $a = $a + "BODY{background-color:peachpuff;}"
                $a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: separate;}"
                $a = $a + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:thistle}"
                $a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:PaleGoldenrod;text-align:center;vertical-align:middle;}"
                $a = $a + "</style>"
                Get-Datastore | Select-Object Name, Type, FreeSpaceMB, CapacityMB, DatastoreBrowserPath | ConvertTo-HTML -head $a -Title "DataStores Inventory" -body "<H2>DataStores Inventory</H2>" | Out-File "$dir\DataStores-Details.htm"
                Invoke-Item "$dir\DataStores-Details.htm"
                $outputTextBox.text = "Exported Successfully in C:\DataStores-Details.htm"
        }
        if (($exporttoOutBoxDataStores.Checked -eq $true) -and ($exporttoCSVDataStores.Checked -eq $true) -and ($exporttoHTMDataStores.Checked -eq $true)) {$outputTextBox.text = "`nAll Files are exported at C:\"}
        }
    catch {  
    $outputTextBox.text = "`nSomething went wrong, please select one checkbox"
    }
}

# Get VMs on ESXI/Hosts/DataStores
function getVmsOnHost{
    try {
		$outputTextBox.text = "`nGetting Virtual Machines on ESXi/Hosts/DataStores: $($HostDropDownBox.SelectedItem.ToString())"		
		$vms = Get-VM | Where-Object {$_.VMHost -eq $(Get-VMHost | Where-Object {$_.Name -eq $HostDropDownBox.SelectedItem.ToString()})} -ErrorAction Stop
		foreach ($vm in $vms) {	
			$VmDropDownBox.Items.Add($vm.Name)	
		}
		$VmDropDownBox.Enabled=$true
        $buttonGetVMs.Enabled = $false
    }
    catch { 
    	$outputTextBox.text = "`nSomething went wrong getting VMs!!"
    }
}

# Get All Details of VMs on ESXI/Hosts/DataStores
function fullDetailsVMs{
    try{
        $outputTextBox.text = "`nGetting All Details of Virtual Machines on ESXi/Hosts/DataStores"
        Get-VM | Select Name, @{N="Cluster";E={Get-Cluster -VM $_}}, `
        @{N="ESX Host";E={Get-VMHost -VM $_}}, `
        @{N="Datastore";E={Get-Datastore -VM $_}}  | sort-object -property Name | Out-Gridview -Title "Virtual Machines Inventory" -Verbose
        }
    catch{
        $outputTextBox.text = "`nSomething went wrong getting VMs!!"
        }
}

# Get Details on VMs Dropdown
function DetailsVMs{
    try{
        $outputTextBox.text = "`nGetting All Details of Virtual Machines on ESXi/Hosts/DataStores"
       Get-VM $($VmDropDownBox.SelectedItem.ToString()) | Select Name,
        @{N="Tools Installed";E={$_.Guest.ToolsVersion -ne ""}},
        @{N="Tools Status";E={$_.ExtensionData.Guest.ToolsStatus}},
        @{N="Tools version";E={if($_.Guest.ToolsVersion -ne ""){$_.Guest.ToolsVersion}}} | sort-object -property Name | Out-Gridview -Title "Virtual Machines Details" -Verbose
        }
    catch{
        $outputTextBox.text = "`nSomething went wrong getting VMs!!"
        }
}

#################################################
#           CONFIGURATION OF FORM
#################################################

##################Main Form Definition
$form = New-Object Windows.Forms.Form
$form.Text = "ESXi Toolbox GUI - Powered by B.I.C Team - ESGI 2017"
$form.Size = New-Object System.Drawing.Size(625,700)
$form.StartPosition = "CenterScreen"
$form.MaximizeBox = $False
$form.MinimizeBox = $False
$form.KeyPreview = $True
$form.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
{$form.Close()}})

##################GroupBox Definition

# Groupbox 1 - vCenter/ESXi Box
$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Location = New-Object System.Drawing.Size(10,5) 
$groupBox1.size = New-Object System.Drawing.Size(190,200) #Width, Heigth
$groupBox1.text = "Connect to vCenter" 
$form.Controls.Add($groupBox1)

# Groupbox 2 - Log Box
$groupBox2 = New-Object System.Windows.Forms.GroupBox
$groupBox2.Location = New-Object System.Drawing.Size(10,550) 
$groupBox2.size = New-Object System.Drawing.Size(460,90) #Width, Heigth
$groupBox2.text = "Output Log:" 
$form.Controls.Add($groupBox2)

# Groupbox 3 - Licenses/NTP on ESXi/Hosts
$groupBox3 = New-Object System.Windows.Forms.GroupBox
$groupBox3.Location = New-Object System.Drawing.Size(210,5) 
$groupBox3.size = New-Object System.Drawing.Size(390,200) #Width, Heigth
$groupBox3.text = "License Key / NTP Server :" 
$form.Controls.Add($groupBox3)

# Groupbox 4 - Services on ESXi Hosts 
$groupBox4 = New-Object System.Windows.Forms.GroupBox
$groupBox4.Location = New-Object System.Drawing.Size(10,215) 
$groupBox4.size = New-Object System.Drawing.Size(590,100) #Width, Heigth
$groupBox4.text = "Services :" 
$form.Controls.Add($groupBox4)

# Groupbox 5 - Inventory 
$groupBox5 = New-Object System.Windows.Forms.GroupBox
$groupBox5.Location = New-Object System.Drawing.Size(10,325) 
$groupBox5.size = New-Object System.Drawing.Size(590,200) #Width, Heigth
$groupBox5.text = "Inventory :" 
$form.Controls.Add($groupBox5) 

##################Label Definition

# IP Address Label
$Label1 = New-Object System.Windows.Forms.Label
$Label1.Location = New-Object System.Drawing.Point(10,20)
$Label1.Size = New-Object System.Drawing.Size(120,14)
$Label1.Text = "IP Address or FQDN:"
$groupBox1.Controls.Add($Label1) #Member of GroupBox1

# Username Label
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Location = New-Object System.Drawing.Point(10,70)
$Label2.Size = New-Object System.Drawing.Size(120,14)
$Label2.Text = "Username:"
$groupBox1.Controls.Add($Label2) #Member of GroupBox1

# Password Label
$Label3 = New-Object System.Windows.Forms.Label
$Label3.Location = New-Object System.Drawing.Point(10,120)
$Label3.Size = New-Object System.Drawing.Size(120,14)
$Label3.Text = "Password:"
$groupBox1.Controls.Add($Label3) #Member of GroupBox1

# Select ESXi/Hosts Label
$Label4= New-Object System.Windows.Forms.Label
$Label4.Location = New-Object System.Drawing.Point(10,20)
$Label4.Size = New-Object System.Drawing.Size(120,14)
$Label4.Text = "Select ESXi/Hosts :"
$groupBox3.Controls.Add($Label4) #Member of GroupBox3

# License Key Label
$Label5 = New-Object System.Windows.Forms.Label
$Label5.Location = New-Object System.Drawing.Point(10,70)
$Label5.Size = New-Object System.Drawing.Size(112,14)
$Label5.Text = "License Key :"
$groupBox3.Controls.Add($Label5) #Member of GroupBox3

# NTP Server Label 
$Label6 = New-Object System.Windows.Forms.Label
$Label6.Location = New-Object System.Drawing.Point(10,120)
$Label6.Size = New-Object System.Drawing.Size(112,14)
$Label6.Text = "NTP Server :"
$groupBox3.Controls.Add($Label6) #Member of GroupBox3

# ESXi/Hosts Inventory Label 
$Label7 = New-Object System.Windows.Forms.Label
$Label7.Location = New-Object System.Drawing.Point(10,25)
$Label7.Size = New-Object System.Drawing.Size(112,14)
$Label7.Text = "Get on ESXi/Hosts :"
$groupBox5.Controls.Add($Label7) #Member of GroupBox5

# DataStores Inventory Label 
$Label8 = New-Object System.Windows.Forms.Label
$Label8.Location = New-Object System.Drawing.Point(75,63)
$Label8.Size = New-Object System.Drawing.Size(90,14)
$Label8.Text = "Get Datastores :"
$groupBox5.Controls.Add($Label8) #Member of GroupBox5

# VMs Inventory Label 
$Label9 = New-Object System.Windows.Forms.Label
$Label9.Location = New-Object System.Drawing.Point(10,100)
$Label9.Size = New-Object System.Drawing.Size(105,14)
$Label9.Text = "Get VMs :"
$groupBox5.Controls.Add($Label9) #Member of GroupBox5

##################Button Definition

# Connect Button
$buttonConnect = New-Object System.Windows.Forms.Button
$buttonConnect.add_click({connectServer})
$buttonConnect.Text = "Connect"
$buttonConnect.Top=170
$buttonConnect.Left=10
$groupBox1.Controls.Add($buttonConnect) #Member of GroupBox1

# Disconnect Button
$buttonDisconnect = New-Object System.Windows.Forms.Button
$buttonDisconnect.add_click({disconnectServer})
$buttonDisconnect.Text = "Disconnect"
$buttonDisconnect.Top=170
$buttonDisconnect.Left=100
$buttonDisconnect.Enabled = $false #Disabled by default
$groupBox1.Controls.Add($buttonDisconnect) #Member of GroupBox1

# View License
$buttonViewLicense = New-Object System.Windows.Forms.Button
$buttonViewLicense.add_click({viewLicense})
$buttonViewLicense.Size = New-Object System.Drawing.Size(110,25) 
$buttonViewLicense.Text = "View License"
$buttonViewLicense.Left=270
$buttonViewLicense.Top=37
$buttonViewLicense.Enabled = $false
$groupBox3.Controls.Add($buttonViewLicense) #Member of GroupBox3

# Update License
$buttonUpdateLicense = New-Object System.Windows.Forms.Button
$buttonUpdateLicense.add_click({updateLicense})
$buttonUpdateLicense.Size = New-Object System.Drawing.Size(110,25) 
$buttonUpdateLicense.Text = "Update License"
$buttonUpdateLicense.Left=270
$buttonUpdateLicense.Top=86
$buttonUpdateLicense.Enabled = $false
$groupBox3.Controls.Add($buttonUpdateLicense) #Member of GroupBox3

# View NTP Server Button
$buttonViewNTP = New-Object System.Windows.Forms.Button
$buttonViewNTP.add_click({ViewNTP})
$buttonViewNTP.Size = New-Object System.Drawing.Size(180,25) 
$buttonViewNTP.Text = "View"
$buttonViewNTP.Left=200
$buttonViewNTP.Top=136
$buttonViewNTP.Enabled = $false
$groupBox3.Controls.Add($buttonViewNTP) #Member of GroupBox3

# Add NTP Server Button
$buttonAddNTP = New-Object System.Windows.Forms.Button
$buttonAddNTP.add_click({addNTP})
$buttonAddNTP.Size = New-Object System.Drawing.Size(85,25) 
$buttonAddNTP.Text = "Add"
$buttonAddNTP.Left=200
$buttonAddNTP.Top=168
$buttonAddNTP.Enabled = $false
$groupBox3.Controls.Add($buttonAddNTP) #Member of GroupBox3

# Remove NTP Server Button
$buttonRemoveNTP = New-Object System.Windows.Forms.Button
$buttonRemoveNTP.add_click({removeNTP})
$buttonRemoveNTP.Size = New-Object System.Drawing.Size(85,25) 
$buttonRemoveNTP.Text = "Remove"
$buttonRemoveNTP.Left=295
$buttonRemoveNTP.Top=168
$buttonRemoveNTP.Enabled = $false
$groupBox3.Controls.Add($buttonRemoveNTP) #Member of GroupBox3

# Get Services Button
$buttonGetServices = New-Object System.Windows.Forms.Button
$buttonGetServices.add_click({getServicesOnHost})
$buttonGetServices.Size = New-Object System.Drawing.Size(140,25) 
$buttonGetServices.Text = "Get Services"
$buttonGetServices.Left=280
$buttonGetServices.Top=18
$buttonGetServices.Enabled = $false
$groupBox4.Controls.Add($buttonGetServices) #Member of GroupBox4

# View Services Button
$buttonViewServices = New-Object System.Windows.Forms.Button
$buttonViewServices.add_click({viewServicesOnHost})
$buttonViewServices.Size = New-Object System.Drawing.Size(140,25) 
$buttonViewServices.Text = "View Services"
$buttonViewServices.Left=440
$buttonViewServices.Top=18
$buttonViewServices.Enabled = $false
$groupBox4.Controls.Add($buttonViewServices) #Member of GroupBox4

# Apply ESXi Only Button
$buttonApplyESXiOnly = New-Object System.Windows.Forms.Button
$buttonApplyESXiOnly.add_click({enabledisableService})
$buttonApplyESXiOnly.Size = New-Object System.Drawing.Size(300,25) 
$buttonApplyESXiOnly.Text = "Apply (ESXi Only)"
$buttonApplyESXiOnly.Left=280
$buttonApplyESXiOnly.Top=60
$buttonApplyESXiOnly.Enabled = $false
$groupBox4.Controls.Add($buttonApplyESXiOnly) #Member of GroupBox4

# Export All Details ESXi Button
$buttonExportESXi = New-Object System.Windows.Forms.Button
$buttonExportESXi.add_click({detailsESXiHosts})
$buttonExportESXi.Size = New-Object System.Drawing.Size(100,25) 
$buttonExportESXi.Text = "All Details"
$buttonExportESXi.Left=380
$buttonExportESXi.Top=20
$buttonExportESXi.Enabled = $false
$groupBox5.Controls.Add($buttonExportESXi) #Member of GroupBox5

# Export Net Details ESXi Button
$buttonExportNetESXi = New-Object System.Windows.Forms.Button
$buttonExportNetESXi.add_click({detailsNetESXiHosts})
$buttonExportNetESXi.Size = New-Object System.Drawing.Size(100,25) 
$buttonExportNetESXi.Text = "Network Details"
$buttonExportNetESXi.Left=480
$buttonExportNetESXi.Top=20
$buttonExportNetESXi.Enabled = $false
$groupBox5.Controls.Add($buttonExportNetESXi) #Member of GroupBox5

# Export All Details DataStores Button
$buttonExportDatastores = New-Object System.Windows.Forms.Button
$buttonExportDatastores.add_click({detailsDataStores})
$buttonExportDatastores.Size = New-Object System.Drawing.Size(130,25) 
$buttonExportDatastores.Text = "All Details"
$buttonExportDatastores.Left=420
$buttonExportDatastores.Top=58
$buttonExportDatastores.Enabled = $false
$groupBox5.Controls.Add($buttonExportDatastores) #Member of GroupBox5

# Get VMs Button
$buttonGetVMs = New-Object System.Windows.Forms.Button
$buttonGetVMs.add_click({getVmsOnHost})
$buttonGetVMs.Size = New-Object System.Drawing.Size(140,25) 
$buttonGetVMs.Text = "Get Virtual Machines"
$buttonGetVMs.Left=280
$buttonGetVMs.Top=118
$buttonGetVMs.Enabled = $false
$groupBox5.Controls.Add($buttonGetVMs) #Member of GroupBox5

# VMs Full Details Button
$buttonDetailsVMs = New-Object System.Windows.Forms.Button
$buttonDetailsVMs.add_click({fullDetailsVMs})
$buttonDetailsVMs.Size = New-Object System.Drawing.Size(140,25) 
$buttonDetailsVMs.Text = "Full Details for VMs"
$buttonDetailsVMs.Left=430
$buttonDetailsVMs.Top=118
$buttonDetailsVMs.Enabled = $false
$groupBox5.Controls.Add($buttonDetailsVMs) #Member of GroupBox5

# VMTools Details Button
$buttonViewVMs = New-Object System.Windows.Forms.Button
$buttonViewVMs.add_click({detailsVMs})
$buttonViewVMs.Size = New-Object System.Drawing.Size(140,25) 
$buttonViewVMs.Text = "VMTools Details"
$buttonViewVMs.Left=280
$buttonViewVMs.Top=158
$buttonViewVMs.Enabled = $false
$groupBox5.Controls.Add($buttonViewVMs) #Member of GroupBox5

##################CheckBox Definition

# ESXi Export to Outbox
$exporttoOutBoxESXi = New-Object System.Windows.Forms.checkbox
$exporttoOutBoxESXi.Location = new-object System.Drawing.Point(125,20) 
$exporttoOutBoxESXi.Size = New-Object System.Drawing.Size(78,27) 
$exporttoOutBoxESXi.Checked = $false
$exporttoOutBoxESXi.Enabled = $false
$exporttoOutBoxESXi.Text = "To Outbox"
$groupBox5.Controls.Add($exporttoOutBoxESXi) #Member of GroupBox3

# ESXi Export to CSV
$exporttoCSVESXi = New-Object System.Windows.Forms.checkbox
$exporttoCSVESXi.Location = new-object System.Drawing.Point(215,20) 
$exporttoCSVESXi.Size = New-Object System.Drawing.Size(70,27)
$exporttoCSVESXi.Checked = $false
$exporttoCSVESXi.Enabled = $false
$exporttoCSVESXi.Text = "To CSV"
$groupBox5.Controls.Add($exporttoCSVESXi) #Member of Group3

# ESXi Export to HTML
$exporttoHTMESXi = New-Object System.Windows.Forms.checkbox
$exporttoHTMESXi.Location = new-object System.Drawing.Point(295,20) 
$exporttoHTMESXi.Size = New-Object System.Drawing.Size(70,27)
$exporttoHTMESXi.Checked = $false
$exporttoHTMESXi.Enabled = $false
$exporttoHTMESXi.Text = "To HTML"
$groupBox5.Controls.Add($exporttoHTMESXi) #Member of Group

# DataStores Export to Outbox
$exporttoOutBoxDataStores = New-Object System.Windows.Forms.checkbox
$exporttoOutBoxDataStores.Location = new-object System.Drawing.Point(175,58) 
$exporttoOutBoxDataStores.Size = New-Object System.Drawing.Size(78,27) 
$exporttoOutBoxDataStores.Checked = $false
$exporttoOutBoxDataStores.Enabled = $false
$exporttoOutBoxDataStores.Text = "To Outbox"
$groupBox5.Controls.Add($exporttoOutBoxDataStores) #Member of GroupBox3

# DataStores Export to CSV
$exporttoCSVDataStores = New-Object System.Windows.Forms.checkbox
$exporttoCSVDataStores.Location = new-object System.Drawing.Point(260,58) 
$exporttoCSVDataStores.Size = New-Object System.Drawing.Size(70,27)
$exporttoCSVDataStores.Checked = $false
$exporttoCSVDataStores.Enabled = $false
$exporttoCSVDataStores.Text = "To CSV"
$groupBox5.Controls.Add($exporttoCSVDataStores) #Member of Group3

# DataStores Export to HTML
$exporttoHTMDataStores = New-Object System.Windows.Forms.checkbox
$exporttoHTMDataStores.Location = new-object System.Drawing.Point(330,58) 
$exporttoHTMDataStores.Size = New-Object System.Drawing.Size(70,27)
$exporttoHTMDataStores.Checked = $false
$exporttoHTMDataStores.Enabled = $false
$exporttoHTMDataStores.Text = "To HTML"
$groupBox5.Controls.Add($exporttoHTMDataStores) #Member of Group

##################RadioButton Definition

# Enable Service
$enableServiceRadioButton = New-Object System.Windows.Forms.RadioButton 
$enableServiceRadioButton.Location = new-object System.Drawing.Point(35,65) 
$enableServiceRadioButton.size = New-Object System.Drawing.Size(100,20) 
$enableServiceRadioButton.checked = $true 
$enableServiceRadioButton.Enabled = $false
$enableServiceRadioButton.Text = "Enable Service" 
$groupBox4.Controls.Add($enableServiceRadioButton) #Member of GroupBox3

# Disable Service
$disableServiceRadioButton = New-Object System.Windows.Forms.RadioButton 
$disableServiceRadioButton.Location = new-object System.Drawing.Point(135,65) 
$disableServiceRadioButton.size = New-Object System.Drawing.Size(110,20) 
$disableServiceRadioButton.Checked = $false 
$disableServiceRadioButton.Enabled = $false
$disableServiceRadioButton.Text = "Disable Service" 
$groupBox4.Controls.Add($disableServiceRadioButton) #Member of GroupBox3

##################TextBox Definition

# Server Textbox
$serverTextBox = New-Object System.Windows.Forms.TextBox 
$serverTextBox.Location = New-Object System.Drawing.Size(10,40) 
$serverTextBox.Size = New-Object System.Drawing.Size(165,20)
$groupBox1.Controls.Add($serverTextBox) #Member of GroupBox1

# Username Textbox
$usernameTextBox = New-Object System.Windows.Forms.TextBox 
$usernameTextBox.Location = New-Object System.Drawing.Size(10,90)
$usernameTextBox.Size = New-Object System.Drawing.Size(165,20) 
$groupBox1.Controls.Add($usernameTextBox) #Member of GroupBox1

# Password Textbox
$passwordTextBox = New-Object System.Windows.Forms.MaskedTextBox 
$passwordTextBox.PasswordChar = '*'
$passwordTextBox.Location = New-Object System.Drawing.Size(10,140)
$passwordTextBox.Size = New-Object System.Drawing.Size(165,20)
$groupBox1.Controls.Add($passwordTextBox) #Member of GroupBox1

# LicenseKey Textbox
$licenseTextBox = New-Object System.Windows.Forms.TextBox 
$licenseTextBox.Location = New-Object System.Drawing.Size(10,90)
$licenseTextBox.Size = New-Object System.Drawing.Size(250,20)
$licenseTextBox.Enabled = $false
$groupBox3.Controls.Add($licenseTextBox) #Member of GroupBox3

# NTP Textbox
$NTPTextBox = New-Object System.Windows.Forms.TextBox 
$NTPTextBox.Location = New-Object System.Drawing.Size(10,140)
$NTPTextBox.Size = New-Object System.Drawing.Size(175,20)
$NTPTextBox.Enabled = $false
$groupBox3.Controls.Add($NTPTextBox) #Member of GroupBox3

# Output Textbox
$outputTextBox = New-Object System.Windows.Forms.TextBox 
$outputTextBox.Location = New-Object System.Drawing.Size(10,20)
$outputTextBox.Size = New-Object System.Drawing.Size(440,60)
$outputTextBox.MultiLine = $True 
$outputTextBox.ReadOnly = $True
$outputTextBox.ScrollBars = "Vertical"  
$groupBox2.Controls.Add($outputTextBox) #Member of groupBox2

##################DropDownBox Definition

# DropbDownBox ESXi/Hosts
$HostDropDownBox = New-Object System.Windows.Forms.ComboBox
$HostDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$HostDropDownBox.Location = New-Object System.Drawing.Size(10,40) 
$HostDropDownBox.Size = New-Object System.Drawing.Size(250,20) 
$HostDropDownBox.DropDownHeight = 200
$HostDropDownBox.Enabled = $false 
$groupBox3.Controls.Add($HostDropDownBox)

# DropbDownBox Services
$ServiceDropDownBox = New-Object System.Windows.Forms.ComboBox
$ServiceDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$ServiceDropDownBox.Location = New-Object System.Drawing.Size(10,20) 
$ServiceDropDownBox.Size = New-Object System.Drawing.Size(250,20) 
$ServiceDropDownBox.DropDownHeight = 200
$ServiceDropDownBox.Enabled = $false 
$groupBox4.Controls.Add($ServiceDropDownBox)

# DropbDownBox Services
$VmDropDownBox = New-Object System.Windows.Forms.ComboBox
$VmDropDownBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$VmDropDownBox.Location = New-Object System.Drawing.Size(10,120) 
$VmDropDownBox.Size = New-Object System.Drawing.Size(250,20) 
$VmDropDownBox.DropDownHeight = 200
$VmDropDownBox.Enabled = $false 
$groupBox5.Controls.Add($VmDropDownBox)

##################School Logo Definition

$file = (get-item "$dir\esgi.png")
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Image = [System.Drawing.Image]::Fromfile($file)
$pictureBox.Location = New-Object System.Drawing.Size(485,570)
$PictureBox.SizeMode = "Zoom"
$form.controls.add($pictureBox)

##################Form View Definition

$form.Add_Shown({$form.Activate()})
[void] $form.ShowDialog()
