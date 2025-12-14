# Définir le chemin du dossier courant où le script est exécuté.
# Cela correspond au dossier contenant les fichiers .pdf.
$SourcePath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Chemin de sortie pour le manifeste
$ManifestPath = Join-Path -Path $SourcePath -ChildPath "manifest.txt"
$Output = @()

Write-Host "Recherche des fichiers .pdf dans : $SourcePath"

# Parcourt tous les fichiers .pdf (y compris dans les sous-dossiers si vous le souhaitez, sinon supprimez -Recurse)
Get-ChildItem -Path $SourcePath -Filter "*.pdf" -File | ForEach-Object {
    # Crée une ligne : Nom_Relatif, Taille, Date_de_modification
    # Note: On utilise le nom relatif (Name) car le client s'attend à ce nom
    $Line = "$($_.Name), $($_.Length), $($_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))"
    $Output += $Line
}

# Écrit le manifeste.txt
$Output | Out-File -FilePath $ManifestPath -Encoding UTF8
Write-Host "--------------------------------------------------------"
Write-Host "Manifeste généré avec succès à l'emplacement : $ManifestPath"
Write-Host "Nombre de fichiers listés : $($Output.Count)"
Write-Host "--------------------------------------------------------"