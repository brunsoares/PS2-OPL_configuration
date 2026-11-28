# Conversão de Jogos PS1 — BIN/CUE para PBP

## Objetivo

Automatizar a conversão de jogos de PlayStation 1 do formato BIN/CUE para EBOOT.PBP, utilizando o **PSXPackager**.

O formato PBP permite executar jogos de PS1 através do Adrenaline no PS Vita.

## Estrutura de Diretórios

```text
PS1/
├── isos_bruta/
│   ├── Jogo 01/
│   │   ├── jogo.cue
│   │   └── jogo.bin
│   ├── Jogo 02/
│   │   ├── jogo.cue
│   │   └── jogo.bin
│   └── ...
│
├── iso_convertida/
│   ├── Jogo 01/
│   │   └── jogo.PBP
│   ├── Jogo 02/
│   │   └── jogo.PBP
│   └── ...
│
└── converter_to_pbp.ps1
```

- **isos_bruta:** contém os jogos originais em BIN/CUE.
- **iso_convertida:** recebe os jogos convertidos para PBP.
- **converter_to_pbp.ps1:** script responsável pela conversão automatizada.

## Requisitos

- Windows com PowerShell.
- PSXPackager CLI instalado.
- PSXPackager necessita de [runtime .NET 10](https://dotnet.microsoft.com/pt-br/download/dotnet/thank-you/runtime-10.0.15-windows-x64-installer?cid=getdotnetcore)
- Jogos de PS1 organizados em pastas individuais, contendo seus respectivos arquivos CUE e BIN.

## Configuração

Antes de executar, configure os caminhos no início do arquivo `converter-ps1.ps1`:

```powershell
$PsxPackager = "C:\PSXPackager\psxpackager.exe"
$Origem = "B:\PS1\isos_bruta"
$Destino = "B:\PS1\iso_convertida"
$Compressao = 5
```

O nível de compressão pode variar de 0 a 9.

## Execução

Abra o PowerShell na pasta do script e execute:

```powershell
.\converter-ps1.ps1
```

O script realiza automaticamente:

1. Identificação das pastas dos jogos na origem.
2. Localização dos arquivos CUE.
3. Criação das respectivas pastas no destino.
4. Conversão dos arquivos para PBP.
5. Exibição do progresso e identificação de erros.

## Regras de Conversão

- Cada jogo deve estar em uma pasta individual.
- A conversão utiliza o arquivo CUE como entrada, permitindo identificar corretamente as faixas BIN associadas.
- Jogos com múltiplos arquivos BIN são suportados.
- Jogos já convertidos são ignorados, evitando processamento duplicado.
- Os arquivos originais não são modificados ou excluídos.
- A estrutura de diretórios dos jogos é preservada no destino.

## Resultado

Ao finalizar, a pasta `iso_convertida` conterá os jogos no formato PBP, organizados individualmente e prontos para transferência ao PS Vita e utilização pelo Adrenaline.

## Referências

- [PsxPackager - Github](https://github.com/RupertAvery/PSXPackager)
- [Rooms - PS1](https://romsfun.com/roms/playstation/)
