function ConvertToBase64String(){
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline = $True, Mandatory = $True)]
        [string]$StringToConvert,
        [bool]$clip, 
        [bool]$WhatIf)

        begin{
            write-verbose " - ConvertToBase64String started"
            $base64AsString = $null;
        }
        process{
            write-verbose " - Converting '$StringToConvert'"
            $base64AsString = [System.Convert]::ToBase64String([System.Text.Encoding]::Default.GetBytes($StringToConvert));
            if($clip) {$base64AsString | clip;}
        }
        end{
            write-verbose " - Value converted '$base64AsString'"
            return $base64AsString;
            write-verbose " - End"
        }
}
