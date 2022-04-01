#Unprotected Endpoints - Not protected by SCEP or Defender
#Add as a powershell widget in a grid view.

$defenderProtected = get-scomclass -DisplayName "protected Endpoint" | where {$_.ManagementPackName -match "Microsoft.WindowsDefender"} | Get-SCOMClassInstance | Select -ExpandProperty name
$scepUnprotected = get-scomclass -DisplayName "unprotected Endpoint" | where {$_.ManagementPackName -match "Microsoft.FEPS.Library"} | Get-SCOMClassInstance | Select -ExpandProperty name

$defenderUnprotected = get-scomclass -DisplayName "unprotected Endpoint" | where {$_.ManagementPackName -match "Microsoft.WindowsDefender"} | Get-SCOMClassInstance | Select -ExpandProperty name
$scepProtected = get-scomclass -DisplayName "protected Endpoint" | where {$_.ManagementPackName -match "Microsoft.FEPS.Library"} | Get-SCOMClassInstance | Select -ExpandProperty name

$Results=@()
#Grab all Unprotected by Defender servers not in SCEP
Foreach ($item in $defenderUnprotected) {   If ($item -notin $scepprotected)     {$Results += $item }}

#Grab all unprotected SCEP servers not in defender.  Safety overkill - the above should actually be enough.  May help Stuck / inccorect / old SCOM AV instance discoveries.
Foreach ($item in $scepUnprotected) {  If ($item -notin $defenderProtected)     { $Results += $Item }}

#Remove dupes
$results=$results | select -Unique

#Display in SCOM
foreach ($one in $results){
   $dataObject = $ScriptContext.CreateInstance("xsd://www.scomathon.com/MySchema");
   $linedata++; 
   $dataObject["Id"]=[string]$linedata;
   $StateIcon=3
   $dataObject["AV Install State"]=$ScriptContext.CreateWellKnownType("xsd://Microsoft.SystemCenter.Visualization.Library!Microsoft.SystemCenter.Visualization.OperationalDataTypes/MonitoringObjectHealthStateType",$StateIcon)
   $dataObject["Name"]=$one
   $ScriptContext.ReturnCollection.Add($dataObject); 
}
