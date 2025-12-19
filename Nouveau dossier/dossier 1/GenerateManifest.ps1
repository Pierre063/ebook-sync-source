# Définir le chemin du dossier courant où le script est exécuté.
# Tous les fichiers et sous-dossiers seront scannés à partir d'ici.
$SourcePath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Chemin de sortie pour le manifeste
$ManifestPath = Join-Path -Path $SourcePath -ChildPath "manifest_recursif.txt"
$Output = @()

Write-Host "Recherche de TOUS les fichiers (y compris sous-dossiers) dans : $SourcePath"

# En-tête du manifeste
$Header = "Chemin_Relatif,Date_Derniere_Modification"
$Output += $Header

# Parcourt TOUS les fichiers dans le dossier courant ET TOUS les sous-dossiers (-Recurse).
Get-ChildItem -Path $SourcePath -File -Recurse | ForEach-Object {
    # 1. Obtenir le chemin complet du fichier
    $FullName = $_.FullName
    
    # 2. Calculer le chemin relatif par rapport au dossier source ($SourcePath)
    # Cela permet d'inclure les noms des sous-dossiers (e.g., "dossier_a/fichier.txt")
    $RelativePath = $FullName.Substring($SourcePath.Length + 1)
    
    # 3. Exclure le manifeste lui-même et le script en cours d'exécution
    if ($_.Name -ne "manifest_recursif.txt" -and $_.Name -ne $MyInvocation.MyCommand.Name) {
        
        $LastWriteDate = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
        
        # Crée la ligne : Chemin_Relatif, Date_de_modification
        $Line = "$RelativePath,$LastWriteDate"
        $Output += $Line
    }
}

# Écrit le manifeste.txt
$Output | Out-File -FilePath $ManifestPath -Encoding UTF8
Write-Host "--------------------------------------------------------"
Write-Host "Manifeste récursif généré avec succès à l'emplacement : $ManifestPath"
Write-Host "Nombre de fichiers listés : $($Output.Count - 1)"
Write-Host "--------------------------------------------------------"