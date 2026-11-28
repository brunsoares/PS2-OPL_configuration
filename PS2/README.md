# Configuração do Open PS2 Loader (OPL)

Este projeto reúne scripts Python e instruções para preparar jogos ISO e configurar uma mídia USB ou SSD para utilização no Open PS2 Loader (OPL) no PlayStation 2.

Os scripts automatizam a identificação do Game ID de cada ISO e a inclusão desse identificador no nome dos arquivos, facilitando a organização e o reconhecimento dos jogos pelo OPL.

Além da automação, este repositório documenta o processo de preparação da mídia, configuração do OPL e inicialização por meio do FunTuna.

## Versões e ferramentas

| Ferramenta   | Versão                   | Funcionalidade                                                         | Observação                                                                                |
| ------------ | ------------------------ | ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| PS2 Slim     | SCPH-90006               | Executa o softmod, aplicativos e OPL.                                  | Configuração validada neste modelo. O comportamento pode variar entre revisões e regiões. |
| LaunchELF    | v4.38                    | Gerenciador de arquivos e aplicativos do PS2.                          | Utilizado para navegar pelos dispositivos e gerenciar arquivos do Memory Card.            |
| FunTuna      | 1.0.10                   | Permite iniciar o ambiente homebrew pelo navegador do Memory Card.     | Instalado no Memory Card do slot 1.                                                       |
| OPL          | 1.2.0 Beta               | Carrega jogos a partir de dispositivos USB e outros meios compatíveis. | Utilizada a build com suporte a exFAT.                                                    |
| SSD/Pendrive | Conforme mídia utilizada | Armazena jogos, capas, configurações e VMCs.                           | SSD SATA de 2,5" conectado por adaptador USB.                                             |
| Python       | 3.x                      | Executa os scripts de inventário e renomeação.                         | Requer Python 3 instalado no Windows.                                                     |

## Requisitos

- PlayStation 2 compatível com a solução de inicialização utilizada.
- FunTuna instalado e funcional no Memory Card.
- Open PS2 Loader 1.2.0 Beta ou versão compatível com exFAT.
- SSD ou pendrive USB.
- Computador com Windows.
- Python 3 instalado e disponível no PATH.
- Arquivos ISO dos jogos que serão utilizados.

## Preparação e formatação da mídia

Para a configuração validada neste projeto, utilize as seguintes propriedades:

| Propriedade             | Configuração          |
| ----------------------- | --------------------- |
| Tabela de partição      | MBR                   |
| Tipo de partição        | Primary (Primária)    |
| Sistema de arquivos     | exFAT                 |
| Quantidade de partições | 1                     |
| Dispositivo utilizado   | SSD SATA 2,5" via USB |

**Observações importantes:**

- O OPL 1.2.0 Beta oferece suporte a FAT32 e exFAT.
- A configuração MBR com uma única partição primária foi validada neste projeto.
- Partições lógicas podem causar problemas de reconhecimento em determinadas configurações.
- A compatibilidade de adaptadores SATA-USB pode variar.
- Faça backup dos arquivos antes de realizar operações de particionamento ou formatação.

A formatação pode ser realizada pelo Gerenciamento de Disco do Windows ou por ferramentas como NIUBI Partition Editor.

## Estrutura esperada da mídia

Os scripts utilizam inicialmente a unidade `B:\` como referência. A estrutura final da mídia deve seguir este padrão:

```text
B:\
|-- CD\
|   |-- SLUS_123.45.Jogo CD.iso
|
|-- DVD\
|   |-- SCUS_123.45.Jogo DVD.iso
|
|-- ART\
|
|-- CFG\
|
|-- VMC\
```

Diretórios:

- `CD`: jogos em formato CD.
- `DVD`: jogos em formato DVD.
- `ART`: capas e imagens dos jogos.
- `CFG`: configurações individuais dos jogos.
- `VMC`: cartões de memória virtuais.

Os diretórios `ART`, `CFG` e `VMC` podem ser utilizados conforme os recursos habilitados no OPL.

## Scripts

### 1. `create_inventory.py`

Analisa as ISOs presentes no diretório de origem, abre o arquivo `SYSTEM.CNF` de cada imagem e tenta identificar o Game ID correspondente.

O script gera o arquivo `B:\list_ps2_iso.csv` com as seguintes colunas:

- `Arquivo`: nome original da ISO.
- `Game ID`: identificador extraído da ISO.
- `Tamanho (MB)`: tamanho aproximado do arquivo.

O script não altera ou renomeia nenhum arquivo.

**Possíveis resultados:**

- `ISO_INVALIDA`: arquivo não reconhecido como ISO válida.
- `ID_NAO_ENCONTRADO`: não foi possível localizar o identificador.
- `ERRO`: ocorreu algum problema durante a leitura.

Arquivos com resultados diferentes de um Game ID válido devem ser verificados manualmente.

### 2. `rename_iso.py`

Lê o relatório `list_ps2_iso.csv` e procura os arquivos ISO nas pastas `B:\CD` e `B:\DVD`.

Para cada correspondência encontrada, o script:

1. Exibe uma prévia dos nomes atuais e dos novos nomes.
2. Informa arquivos ignorados, já prefixados ou ausentes no CSV.
3. Solicita confirmação digitando `RENOMEAR`.
4. Renomeia os arquivos adicionando o Game ID como prefixo.

Exemplo:

```text
jogo.iso -> SLUS_213.06.jogo.iso
```

O conteúdo das ISOs não é modificado; somente o nome dos arquivos é alterado.

O script também evita sobrescrever arquivos existentes.

## Como executar no Windows

### 1. Instale o Python

Instale o Python 3 e marque a opção para adicionar o executável ao `PATH` do Windows.

### 2. Prepare os diretórios

Organize as ISOs conforme a estrutura esperada pelos scripts.

O fluxo recomendado é:

1. Colocar as ISOs originais no diretório de origem configurado no inventário.
2. Executar o inventário para identificar os Game IDs.
3. Classificar os jogos nas pastas `CD` e `DVD`.
4. Executar o script de renomeação.

### 3. Gere o inventário

Abra o PowerShell na pasta do projeto e execute:

```powershell
python create_inventory.py
```

Ao finalizar, será criado o arquivo:

```text
B:\list_ps2_iso.csv
```

Revise o relatório e verifique se os Game IDs foram extraídos corretamente.

### 4. Renomeie as ISOs

Execute:

```powershell
python rename_iso.py
```

O programa exibirá uma prévia antes de alterar os arquivos.

Para confirmar a operação, digite exatamente:

```text
RENOMEAR
```

Pressione `ENTER` em qualquer outra resposta para cancelar.

### 5. Transfira os arquivos para a mídia

Após a renomeação, transfira as pastas `CD` e `DVD` para a raiz do SSD ou pendrive.

A estrutura final deverá corresponder à apresentada anteriormente.

## Formato dos nomes no OPL

Os arquivos devem seguir o padrão:

```text
<GAME_ID>.<nome_da_iso>.iso
```

Exemplo:

```text
SLUS_213.06.Resident Evil 4.iso
```

O identificador deve ser extraído da própria ISO. Não utilize identificadores inventados ou copiados de outra versão do jogo.

A utilização do Game ID no nome facilita a identificação dos jogos e a aplicação de configurações individuais no OPL.

## Configuração do Open PS2 Loader

Para utilizar os jogos armazenados em USB, configure o OPL conforme os parâmetros abaixo:

| Configuração        | Valor |
| ------------------- | ----- |
| BDM Start Mode      | Auto  |
| Block Devices > USB | ON    |
| Fonte dos jogos     | BDM   |
| Sistema de arquivos | exFAT |

Após alterar as configurações:

1. Selecione `OK` para aplicar as alterações.
2. Retorne ao menu principal.
3. Utilize `Save Changes` para salvar as configurações.
4. Acesse a fonte BDM para visualizar os jogos.

**Observação:** BDM é o mecanismo utilizado pelo OPL para acessar dispositivos de armazenamento, incluindo USB.

## Inicialização pelo FunTuna

Na configuração validada com o PS2 Slim SCPH-90006, foi necessário conectar o SSD somente depois de iniciar o FunTuna.

Procedimento:

1. Ligue o PS2 sem o SSD conectado.
2. Acesse o navegador do Memory Card.
3. Aguarde a inicialização do FunTuna.
4. Após o carregamento do menu, conecte o SSD na porta USB.
5. Inicie o Open PS2 Loader.

**Observação:** conectar o SSD antes da inicialização provocava travamento na tela inicial do FunTuna neste ambiente. Esse comportamento pode variar conforme o dispositivo USB e a configuração utilizada.

## Memory Card virtual (VMC)

O OPL oferece suporte a cartões de memória virtuais, permitindo armazenar os saves diretamente no dispositivo USB.

Os arquivos VMC ficam armazenados na pasta `VMC` da mídia.

É possível configurar cartões virtuais individualmente para cada jogo.

Exemplo:

| Jogo                   | Cartão virtual | Capacidade |
| ---------------------- | -------------- | ---------- |
| God of War             | VMC próprio    | 8 MB       |
| GTA San Andreas        | VMC próprio    | 8 MB       |
| Shadow of the Colossus | VMC próprio    | 8 MB       |

Para configurar:

1. Selecione o jogo na lista do OPL.
2. Pressione `Triângulo`.
3. Acesse `Game Settings`.
4. Entre em `Configure VMC`.
5. Selecione o slot desejado.
6. Crie o cartão virtual com a capacidade escolhida.
7. Salve as configurações.

Cada jogo pode utilizar seu próprio VMC ou compartilhar um cartão virtual com outros jogos.

**Recomendação:** utilizar VMCs individuais de 8 MB para facilitar a organização e os backups.

Mantenha cópias de segurança periódicas da pasta `VMC`.

## Solução de problemas

| Problema                        | Possível causa                           | Solução                                                         |
| ------------------------------- | ---------------------------------------- | --------------------------------------------------------------- |
| Jogos não aparecem no OPL       | Nome dos arquivos sem Game ID            | Executar o script de renomeação.                                |
| Jogos não aparecem no OPL       | Estrutura de diretórios incorreta        | Verificar as pastas `CD` e `DVD` na raiz da mídia.              |
| SSD não é reconhecido           | Partição lógica em vez de primária       | Verificar o tipo de partição e utilizar uma partição primária.  |
| SSD não é reconhecido           | Incompatibilidade do adaptador SATA-USB  | Testar outro adaptador compatível.                              |
| FunTuna trava na inicialização  | Dispositivo USB conectado durante o boot | Inicializar o FunTuna sem o SSD e conectá-lo depois.            |
| Jogos não carregam corretamente | Problemas específicos de compatibilidade | Consultar as configurações individuais e a documentação do OPL. |

## Observações e limitações

- A configuração documentada foi testada em um PS2 Slim SCPH-90006.
- O funcionamento pode variar conforme o modelo, região, versão do OPL e dispositivo de armazenamento.
- O carregamento por USB possui limitações de velocidade em comparação com outras soluções de armazenamento compatíveis.
- A compatibilidade de adaptadores SATA-USB não é garantida.
- O uso de VMC depende da compatibilidade do jogo com o recurso.
- Os scripts não modificam o conteúdo das ISOs.
- Sempre mantenha backups das ISOs, configurações e arquivos VMC.

## Referências

- [Open PS2 Loader - GitHub](https://github.com/ps2homebrew/Open-PS2-Loader)
- [ConsoleMods - Open PS2 Loader](<https://consolemods.org/wiki/PS2:Open_PS2_Loader_(OPL)>)
- [FunTuna - GitHub](https://github.com/MechaResearch/MechaPwn)
- [Python - Downloads](https://www.python.org/downloads/)
- [Roms - PS2](https://romsfun.com/roms/playstation-2/)
