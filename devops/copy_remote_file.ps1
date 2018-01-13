#  Copy files and validate
# Must run as administrator
Enable-PsRemoting -Force
param (
  [string]$version_path,
  [string]$schema_path
)
# Build a credential - you can do this in another file for security
$localuser = "dbmguest"
$server = "10.0.0.12"
$domain = "DBMTemplate"
$username = "$domain\$env:bamboo_dbm_username"
$password = "$env:bamboo_dbm_password"
$auto_path = "$env:bamboo_dbm_base_path"
$automation_path = "$env:bamboo_dbm_automation_dir"
$java_cmd = "$env:bamboo_dbm_java_cmd"
$pipeline = "$env:bamboo_dbm_pipeline"
$dbm_task = "Package"
$version = "$env:bamboo_dbm_version"
$env = "$env:bamboo_dbm_environment"
$scp_package_source = ($version_path -replace "\\", "/")
$base_schema = "HR_INTEGRATION"
write-host "#=> Changing user to $username"

$cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
#$sess = New-PSSession -ComputerName $server -Credential $cred

write-Host "#----- Release $env:Bamboo_deploy_version -----#"
write-Host "# Copying file: $scp_package_source"
write-Host "#           To: \\$server:$auto_path\$base_schema"
[String]$dbm_cmd = @"
C:;
cd $auto_path\$base_schema
C:\Automation\OpenSSH-Win64\scp.exe $username@pocintegration:/$scp_package_source .
"@
# invoke
write-Host "#=> Running: $dbm_cmd"
[ScriptBlock]$script = [ScriptBlock]::Create($dbm_cmd)
Invoke-Command -ComputerName $server -Credential $cred -ScriptBlock $script -ErrorVariable errmsg

# Now run the automation command
# Build with here string
# java -jar DBmaestroAgent.jar -Validate  -ProjectName human_resources -EnvName integration -Server 10.1.0.15 -PackageName V1.0.1
[String]$dbm_cmd = @"
C:;
cd "$auto_path" 
$java_cmd -$dbm_task -ProjectName $pipeline -Server $server
"@
# invoke
write-Host "#=> Running: $dbm_cmd"
[ScriptBlock]$script = [ScriptBlock]::Create($dbm_cmd)
Invoke-Command -ComputerName $server -Credential $cred -ScriptBlock $script -ErrorVariable errmsg
#if ($LASTEXITCODE -ne 0) {
#  exit(1)
#}