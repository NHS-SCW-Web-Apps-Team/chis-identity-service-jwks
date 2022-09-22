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
#ssh-keygen -t rsa -b 4096 -m PEM -f $privatekey

$PublicKeyOpenSSH = $keypath+"/jwtRS512.pub"
$publicKeyPEM =$keypath+"/jwtRS512.key.pub" 

if($IsWindows){
    ssh-keygen -t rsa -b 4096 -m PEM -f $privatekey
    ssh-keygen -f $PublicKeyOpenSSH -e -m pem > $publicKeyPEM 
}else{
    # added but untested ... "should work "
    $UnixPrivateKeyPath = $privatekey+".key"
    ssh-keygen -t rsa -b 4096 -m PEM -f $UnixPrivateKeyPath 
    openssl rsa -in $UnixPrivateKeyPath -pubout -outform PEM -out $publicKeyPEM
}

Copy-Item -Path $privatekey -Destination $privatekey".key" 
#Copy-Item -Path $publicKeyPEM  -Destination $privatekey".jwks"

pem-jwk $publicKeyPEM > $privatekey"Public.jwks"

$jwks = Get-Content -Path $privatekey"Public.jwks" -Raw 

$n = $jwks| ConvertFrom-Json 

$jwksFileName = Read-Host "set filename for JWKS output" .\.env 
$jwksFileName= $jwksFileName.trim()
if($jwksFileName.Length -eq 0){
    $jwksPath=$privatekey+"jwks"
}else{
    $jwksPath=$keypath+"/"+$jwksFileName
}

# pem-jwk $publicKeyPEM > $jwksPath.jwks

@{keys=@(@{kty="RSA"; e="AQAB";kid=$kid;use="sig";n=$n.n})} | ConvertTo-Json | Set-Content $jwksPath".json"