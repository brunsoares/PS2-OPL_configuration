# Configuração e organização de jogos PlayStation

Este repositório reúne scripts e instruções para organizar jogos e preparar arquivos para uso em consoles PlayStation. O conteúdo está separado por plataforma e inclui automações para identificar e renomear ISOs de PS2, converter jogos de PS1 para PBP e compactar ISOs de PSP para CSO.

## Conteúdo

| Pasta                | Conteúdo                                                                                                                                       |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [PS1](PS1/README.md) | Conversão de jogos BIN/CUE para PBP, para uso pelo Adrenaline no PS Vita.                                                                      |
| [PS2](PS2/README.md) | Inventário de ISOs, identificação do Game ID e renomeação para organização e uso no Open PS2 Loader (OPL), além de instruções de configuração. |
| [PSP](PSP/README.md) | Conversão de arquivos ISO para CSO, reduzindo o espaço ocupado para uso no PSP ou pelo Adrenaline no PS Vita.                                  |

## Antes de executar

- Consulte o README da plataforma correspondente: ele descreve os requisitos, a configuração e o modo de execução de cada script.
- Confira e ajuste nos scripts os caminhos de origem, destino e das ferramentas externas para o seu ambiente.
- Mantenha cópias de segurança dos arquivos originais. As conversões geram arquivos em outro formato; o fluxo de PS2 também pode renomear ISOs após confirmação.
