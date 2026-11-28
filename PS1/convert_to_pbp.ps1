# CONFIGURAÇÕES
$PsxPackager = "B:<diretorio_instalacao_psxpackager>\psxpackager.exe"
$Origem = "B:<diretorio_instalacao_arquivos_bin_cue>\jogos_bruto"
$Destino = "B:<direotio_conversao_dos_arquivos>\jogos_convertidos"
$Compressao = 5

# Validar caminhos
if (!(Test-Path $PsxPackager)) {
    throw "PSXPackager não encontrado: $PsxPackager"
}

if (!(Test-Path $Origem)) {
    throw "Pasta de origem não encontrada: $Origem"
}

New-Item -ItemType Directory -Force -Path $Destino | Out-Null

# Localizar pastas dos jogos
$Jogos = Get-ChildItem -Path $Origem -Directory

$Total = $Jogos.Count
$Atual = 0

foreach ($Jogo in $Jogos) {

    $Atual++

    Write-Host "`n[$Atual/$Total] $($Jogo.Name)" -ForegroundColor Cyan

    # Localizar CUEs do jogo
    $Cues = Get-ChildItem -Path $Jogo.FullName -Filter "*.cue" -File

    if ($Cues.Count -eq 0) {
        Write-Host "Nenhum CUE encontrado. Pulando..." -ForegroundColor Yellow
        continue
    }

    # Criar pasta de destino
    $PastaDestino = Join-Path $Destino $Jogo.Name

    New-Item -ItemType Directory -Force -Path $PastaDestino | Out-Null

    foreach ($Cue in $Cues) {

        $NomePbp = [IO.Path]::GetFileNameWithoutExtension($Cue.Name) + ".PBP"
        $ArquivoFinal = Join-Path $PastaDestino $NomePbp

        if (Test-Path $ArquivoFinal) {
            Write-Host "Já convertido: $NomePbp" -ForegroundColor Yellow
            continue
        }

        Write-Host "Convertendo: $($Cue.Name)"

        & $PsxPackager `
            -i $Cue.FullName `
            -o $PastaDestino `
            -l $Compressao

        if ($LASTEXITCODE -eq 0 -and (Test-Path $ArquivoFinal)) {
            Write-Host "Conversão concluída!" -ForegroundColor Green
        }
        else {
            Write-Host "ERRO na conversão: $($Cue.Name)" -ForegroundColor Red
        }
    }
}

Write-Host "`nProcessamento finalizado!" -ForegroundColor Green
