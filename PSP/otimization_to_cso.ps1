# Configurações
$MaxCSO = "G:\bkps_hds\maxcso.exe"
$Origem = "G:\bkps_hds\ISOS_VITA\pspemu\ISO\iso_bruta"
$Destino = "G:\bkps_hds\ISOS_VITA\pspemu\ISO\iso_convertida"
$Formato = "cso1"
$Bloco = 2048

# Contadores
$Convertidos = 0
$Ignorados = 0
$Falhas = 0

# Totais
$TotalOriginal = [long]0
$TotalConvertido = [long]0

# Resultados individuais
$Resultados = @()

# Validação dos caminhos
if (!(Test-Path -LiteralPath $MaxCSO)) {
    Write-Host "ERRO: MaxCSO nao encontrado!" -ForegroundColor Red
    exit
}

if (!(Test-Path -LiteralPath $Origem)) {
    Write-Host "ERRO: Pasta de origem nao encontrada!" -ForegroundColor Red
    exit
}

New-Item -ItemType Directory -Force -Path $Destino | Out-Null

$ISOs = Get-ChildItem -LiteralPath $Origem -Filter "*.iso" -File

# Indexa os CSOs existentes pelo nome-base
$CSOsExistentes = @{}

Get-ChildItem -LiteralPath $Destino -Filter "*.cso" -File |
    ForEach-Object {
        $CSOsExistentes[$_.BaseName.ToLowerInvariant()] = $_
    }

Write-Host "`n=========================================="
Write-Host " INICIANDO CONVERSAO PSP"
Write-Host "=========================================="

Write-Host "Total de ISOs encontrados: $($ISOs.Count)"
Write-Host "Total de CSOs existentes: $($CSOsExistentes.Count)"

# Processamento de cada ISO para conversão em CSO
$Indice = 0

foreach ($Iso in $ISOs) {

    $Indice++

    $NomeBase = $Iso.BaseName
    $NomeChave = $NomeBase.ToLowerInvariant()

    $ArquivoFinal = Join-Path $Destino "$NomeBase.cso"

    $TamanhoOriginal = [long]$Iso.Length
    $TamanhoConvertido = [long]0

    $Status = ""

    Write-Host "`n[$Indice/$($ISOs.Count)] $($Iso.Name)"

    # Verifica se o CSO já existe e não está vazio
    if ($CSOsExistentes.ContainsKey($NomeChave)) {

        $CSO = $CSOsExistentes[$NomeChave]

        if ($CSO.Length -gt 0) {

            $TamanhoConvertido = [long]$CSO.Length

            $Status = "IGNORADO"
            $Ignorados++

            Write-Host "Arquivo ja convertido. Ignorando..." -ForegroundColor Yellow
        }
        else {

            $Status = "FALHA - CSO vazio"
            $Falhas++

            Write-Host "Arquivo CSO existente, mas vazio!" -ForegroundColor Red
        }
    } else {
        # Se o CSO não existe, realiza a conversão
        Write-Host "Convertendo..." -ForegroundColor Cyan

        & $MaxCSO "--format=$Formato" "--block=$Bloco" $Iso.FullName -o $ArquivoFinal

        $CodigoSaida = $LASTEXITCODE

        # Verifica diretamente o caminho completo
        if (Test-Path -LiteralPath $ArquivoFinal -PathType Leaf) {

            $ArquivoGerado = Get-Item -LiteralPath $ArquivoFinal

            if ($ArquivoGerado.Length -gt 0) {

                $TamanhoConvertido = [long]$ArquivoGerado.Length

                if ($CodigoSaida -eq 0) {

                    $Status = "CONVERTIDO"
                    $Convertidos++

                    $CSOsExistentes[$NomeChave] = $ArquivoGerado

                    Write-Host "Conversao concluida!" -ForegroundColor Green
                }
                else {

                    $Status = "AVISO - codigo $CodigoSaida"
                    $Falhas++

                    Write-Host "Arquivo gerado, mas codigo de saida diferente de zero." -ForegroundColor Yellow
                }
            }
            else {

                $Status = "FALHA - arquivo vazio"
                $Falhas++

                Write-Host "Arquivo CSO vazio!" -ForegroundColor Red
            }
        }
        else {

            $Status = "FALHA - arquivo nao encontrado"
            $Falhas++

            Write-Host "Arquivo CSO nao encontrado!" -ForegroundColor Red
            Write-Host "Caminho esperado: $ArquivoFinal"
            Write-Host "Codigo de saida: $CodigoSaida"
        }
    }

    # Calcula a redução de tamanho e atualiza os totais
    if ($TamanhoConvertido -gt 0) {

        $Reducao = (
            ($TamanhoOriginal - $TamanhoConvertido) /
            $TamanhoOriginal
        ) * 100

        $TotalOriginal += $TamanhoOriginal
        $TotalConvertido += $TamanhoConvertido

        $Resultados += [PSCustomObject]@{
            Jogo = $NomeBase
            OriginalMB = [math]::Round($TamanhoOriginal / 1MB, 2)
            CSOMB = [math]::Round($TamanhoConvertido / 1MB, 2)
            Reducao = "$([math]::Round($Reducao, 2))%"
            Status = $Status
        }

        Write-Host "Reducao: $([math]::Round($Reducao, 2))%"
    }
    else {

        $Resultados += [PSCustomObject]@{
            Jogo = $NomeBase
            OriginalMB = [math]::Round($TamanhoOriginal / 1MB, 2)
            CSOMB = 0
            Reducao = "N/A"
            Status = $Status
        }
    }
}

# Relatório por jogo
Write-Host "`n=========================================="
Write-Host " RELATORIO POR JOGO"
Write-Host "=========================================="

$Resultados | Format-Table -AutoSize

$ReducaoTotal = 0

if ($TotalOriginal -gt 0) {

    $ReducaoTotal = (
        ($TotalOriginal - $TotalConvertido) /
        $TotalOriginal
    ) * 100
}

# Relatório final
Write-Host "`n=========================================="
Write-Host " RELATORIO FINAL"
Write-Host "=========================================="

Write-Host "Total de ISOs: $($ISOs.Count)"
Write-Host "Convertidos: $Convertidos"
Write-Host "Ignorados: $Ignorados"
Write-Host "Falhas: $Falhas"

Write-Host "`nTamanho original: $([math]::Round($TotalOriginal / 1GB, 2)) GB"
Write-Host "Tamanho CSO: $([math]::Round($TotalConvertido / 1GB, 2)) GB"

Write-Host "Reducao total: $([math]::Round($ReducaoTotal, 2))%"

Write-Host "`n=========================================="
Write-Host " PROCESSAMENTO FINALIZADO"
Write-Host "=========================================="
