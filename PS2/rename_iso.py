import csv
import re
from pathlib import Path

# Configuração de caminhos e padrões
BASE = Path(r"B:<diretorio_instalacao_arquivos_iso>")
CSV_PATH = BASE / "list_ps2_iso.csv"
PASTAS_JOGOS = [BASE / "CD", BASE / "DVD"]

# Aceita identificadores como SLUS_213.06, SCUS_971.13 ou SLES_550.52
PADRAO_ID = re.compile(r"^[A-Z]{4}_\d{3}\.\d{2}$", re.IGNORECASE)

# Função para carregar o inventário do CSV
def carregar_inventario():
    if not CSV_PATH.exists():
        raise FileNotFoundError(
            f"CSV não encontrado: {CSV_PATH}\n"
            f"Coloque list_ps2_iso.csv nessa pasta."
        )

    inventario = {}
    # Lê o CSV e cria um dicionário com os nomes originais e seus respectivos Game IDs
    with CSV_PATH.open("r", encoding="utf-8-sig", newline="") as arquivo:
        leitor = csv.DictReader(arquivo, delimiter=";")

        colunas = {"Arquivo", "Game ID"}
        if not colunas.issubset(leitor.fieldnames or []):
            raise ValueError(
                "O CSV precisa conter as colunas 'Arquivo' e 'Game ID'."
            )

        for linha in leitor:
            nome_original = (linha.get("Arquivo") or "").strip()
            game_id = (linha.get("Game ID") or "").strip().upper()

            if not nome_original or not PADRAO_ID.fullmatch(game_id):
                print(
                    f"[IGNORADO] Registro sem nome ou ID válido: "
                    f"{nome_original!r} / {game_id!r}"
                )
                continue

            inventario[nome_original.casefold()] = game_id

    return inventario


def main():
    inventario = carregar_inventario()

    operacoes = []
    ignorados = []
    ausentes = []

    for pasta in PASTAS_JOGOS:
        if not pasta.exists():
            print(f"[AVISO] Pasta não encontrada: {pasta}")
            continue

        for arquivo in pasta.iterdir():
            if not arquivo.is_file() or arquivo.suffix.lower() != ".iso":
                continue

            # Localiza a ISO pelo nome original registrado no CSV.
            game_id = inventario.get(arquivo.name.casefold())

            if not game_id:
                # Se já estiver prefixada, não adiciona outro prefixo.
                if re.match(r"^[A-Z]{4}_\d{3}\.\d{2}\.", arquivo.name, re.I):
                    ignorados.append((arquivo, "já possui prefixo"))
                else:
                    ausentes.append(arquivo)
                continue

            prefixo = game_id + "."
            if arquivo.name.upper().startswith(prefixo.upper()):
                ignorados.append((arquivo, "já possui o prefixo correto"))
                continue

            novo_nome = prefixo + arquivo.name
            destino = arquivo.with_name(novo_nome)

            if destino.exists():
                ignorados.append((arquivo, f"destino já existe: {destino.name}"))
                continue

            operacoes.append((arquivo, destino))

    print("\nPRÉVIA — nenhum arquivo foi alterado ainda\n")
    for origem, destino in operacoes:
        print(f"{origem.name}\n  -> {destino.name}")

    print("\nResumo:")
    print(f"  Renomeações previstas: {len(operacoes)}")
    print(f"  Ignorados: {len(ignorados)}")
    print(f"  Não encontrados no CSV: {len(ausentes)}")

    for arquivo, motivo in ignorados:
        print(f"  [IGNORADO] {arquivo.name}: {motivo}")

    for arquivo in ausentes:
        print(f"  [SEM ID NO CSV] {arquivo.name}")

    if not operacoes:
        print("\nNenhuma renomeação necessária.")
        return

    resposta = input(
        "\nDigite RENOMEAR para aplicar as alterações; "
        "qualquer outra resposta cancela: "
    ).strip()

    if resposta != "RENOMEAR":
        print("Operação cancelada. Nenhum arquivo foi alterado.")
        return

    sucesso = 0
    falhas = 0

    for origem, destino in operacoes:
        try:
            # Evita sobrescrever qualquer arquivo existente.
            if destino.exists():
                print(f"[CONFLITO] {destino.name} já existe; ignorado.")
                falhas += 1
                continue

            origem.rename(destino)
            print(f"[OK] {origem.name} -> {destino.name}")
            sucesso += 1
        except OSError as erro:
            print(f"[ERRO] {origem.name}: {erro}")
            falhas += 1

    print("\nConcluído:")
    print(f"  Renomeados: {sucesso}")
    print(f"  Falhas/conflitos: {falhas}")
    print("Os arquivos ISO não foram modificados; somente os nomes mudaram.")


if __name__ == "__main__":
    try:
        main()
    except Exception as erro:
        print(f"\nERRO: {erro}")

    input("\nPressione ENTER para fechar...")
