param(  [string] $env,
        [string] $kid
)

if($env.length -eq 0){
    Write-Host("Not valid instruction expected -env value : sandbox/dev/int/prod")
    Exit
}
if($kid.length -eq 0){
    Write-Host("Not valid instruction expected -kid value ")
    Exit
}

$keypath = ".\"+$env+"\"+$kid

if (Test-Path $keypath){
    Write-Host(".\"+$env+"\"+$kid+" folder already Exists")
    Exit
}else {
    <# Action when all if and elseif conditions are false #>
    New-Item -Path $keypath -ItemType Directory
}

$privatekey = $keypath+"/jwtRS512"
ssh-keygen -t rsa -b 4096 -m PEM -f $privatekey

$PublicKeyOpenSSH = $keypath+"/jwtRS512.pub"
$publicKeyPEM =$keypath+"/jwtRS512.key.pub" 
ssh-keygen -f $PublicKeyOpenSSH -e -m pem > $publicKeyPEM 

Copy-Item -Path $privatekey -Destination $privatekey".key" 
Copy-Item -Path $publicKeyPEM  -Destination $privatekey".jwks"

(Get-Content -Path $privatekey".jwks" -Raw ) -replace "-----BEGIN RSA PUBLIC KEY-----","" -replace "-----END RSA PUBLIC KEY-----","" -replace "`r`n" ,""  | Set-Content $privatekey".jwks"

$n = Get-Content -Path $privatekey".jwks"

$jwksFileName = Read-Host "set filename for JWKS output" .\.env 

if($jwksFileName.Length -eq 0){
    $jwksPath=$privatekey+"jwks"
}else{
    $jwksPath=$keypath+"/"+$jwksFileName
}

@{keys=@(@{kty="RSA"; e="AQAB";kid=$kid;use="sig";n=$n})} | ConvertTo-Json | Set-Content $jwksPath".json"