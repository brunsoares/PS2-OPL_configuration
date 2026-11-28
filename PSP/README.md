# Conversão de jogos PSP — ISO para CSO

## Objetivo

Converter arquivos de jogos PSP do formato `.ISO` para `.CSO`, reduzindo o espaço ocupado no armazenamento sem precisar manter duas cópias dos jogos.

A conversão é realizada pelo **MaxCSO**, utilizando o formato CSO1 e blocos de 2048 bytes.

## Estrutura de diretórios

```text
PSP/
├── maxcso.exe
├── converter_to_cso.ps1
│
├── iso_bruta/
│   ├── Jogo 1.iso
│   ├── Jogo 2.iso
│   └── ...
│
└── iso_convertida/
    ├── Jogo 1.cso
    ├── Jogo 2.cso
    └── ...
```

- `maxcso.exe`: ferramenta responsável pela conversão.
- `converter_to_cso.ps1`: script PowerShell que automatiza o processo.
- `iso_bruta/`: diretório dos arquivos ISO originais.
- `iso_convertida/`: diretório de destino dos arquivos CSO.

## Requisitos

- Windows com PowerShell.
- MaxCSO instalado ou disponível no diretório configurado no script.
- Arquivos de jogos PSP no formato `.ISO`.

## Configuração

Antes de executar, confira os caminhos configurados no início do arquivo `converter_to_cso.ps1`:

- Caminho do executável MaxCSO.
- Diretório de origem.
- Diretório de destino.
- Formato de compressão (`cso1`).
- Tamanho do bloco (`2048`).

## Execução

1. Coloque os arquivos ISO na pasta `iso_bruta`.
2. Abra o PowerShell no diretório do script.
3. Execute:

```powershell
.\converter_to_cso.ps1
```

O script percorre os arquivos ISO e realiza a conversão para CSO.

## Comportamento do script

- Identifica os arquivos ISO disponíveis na pasta de origem.
- Verifica se o arquivo CSO correspondente já existe no destino.
- Ignora arquivos que já foram convertidos.
- Converte apenas os arquivos ainda não processados.
- Verifica a existência e o tamanho dos arquivos gerados.
- Apresenta um relatório final com a quantidade de arquivos convertidos, ignorados e com falha.

## Observações

- Os arquivos ISO originais são preservados.
- Os arquivos CSO são destinados ao uso no PSP por meio do Adrenaline no PS Vita.
- A taxa de compressão varia de acordo com o conteúdo de cada jogo.
- Não é necessário converter novamente arquivos CSO já existentes.

## Referências

- [MaxCSO - Github](https://github.com/unknownbrackets/maxcso)
- [Roms - PSP - NoPayStation](https://www.cfwaifu.com/nopaystation//)
- [Roms - PSP - RomsFun](https://romsfun.com/roms/playstation-portable/)
- [Adrenaline - PSVita](https://adrenaline.sarcasticat.com/docs)
