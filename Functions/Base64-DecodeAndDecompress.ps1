function Base64-DecodeAndDecompress {
    param (
        [Parameter(Mandatory = $true)]
        [string]$base64String
    )

    try {
        # Decode the Base64 string to a byte array
        $decodedBytes = [System.Convert]::FromBase64String($base64String)

        # Create a MemoryStream from the byte array
        $memoryStream = New-Object System.IO.MemoryStream(, $decodedBytes)

        # Create a GZipStream to decompress
        $gzipStream = New-Object System.IO.Compression.GzipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)

        # Create a StreamReader to read the decompressed data with default encoding (UTF-8)
        $streamReader = New-Object System.IO.StreamReader($memoryStream, [System.Text.Encoding]::UTF8)

        # Read the decompressed string
        $decompressedString = $streamReader.ReadToEnd()

        
        # Output the decompressed string
        return $decompressedString

        
    } catch {
        return "The input is not a valid Base64 encoded or Gzip compressed string, or there was an error during decoding."
    }
    finally {
        # Clean up resources
        if ($gzipStream) { $gzipStream.Dispose() }
        if ($memoryStream) { $memoryStream.Dispose() }
        if ($streamReader) { $streamReader.Dispose() }
    }
}