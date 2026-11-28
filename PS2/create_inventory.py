import os
import re
import csv

ORIGEM = r"B:<diretorio_instalacao_arquivos_iso>"
RELATORIO = r"B:<diretorio_instalacao_arquivos_iso>\list_ps2_iso.csv"

SECTOR_SIZE = 2048


# Função para extrair o Game ID de um arquivo ISO
def extrair_id_iso(caminho):
    try:
        with open(caminho, "rb") as iso:
            # Primary Volume Descriptor
            iso.seek(16 * SECTOR_SIZE)
            pvd = iso.read(SECTOR_SIZE)

            if len(pvd) != SECTOR_SIZE:
                return "ISO_INVALIDA"

            if pvd[1:6] != b"CD001":
                return "FORMATO_NAO_RECONHECIDO"

            # Registro do diretório raiz
            root = pvd[156:]
            extent = int.from_bytes(root[2:6], "little")
            size = int.from_bytes(root[10:14], "little")

            iso.seek(extent * SECTOR_SIZE)
            directory = iso.read(size)

            offset = 0

            while offset < len(directory):
                record_length = directory[offset]

                if record_length == 0:
                    offset = ((offset // SECTOR_SIZE) + 1) * SECTOR_SIZE
                    continue

                record = directory[offset:offset + record_length]

                if len(record) < 34:
                    break

                name_length = record[32]
                name = record[33:33 + name_length].decode(
                    "ascii", errors="ignore"
                ).upper()

                if name.split(";")[0] == "SYSTEM.CNF":
                    file_extent = int.from_bytes(record[2:6], "little")
                    file_size = int.from_bytes(record[10:14], "little")

                    iso.seek(file_extent * SECTOR_SIZE)
                    system_cnf = iso.read(file_size).decode(
                        "ascii", errors="ignore"
                    )

                    match = re.search(
                        r"\b([A-Z]{4}[_-]\d{3}\.\d{2})\b",
                        system_cnf,
                        re.IGNORECASE
                    )

                    return match.group(1).upper() if match else "ID_NAO_ENCONTRADO"

                offset += record_length

        return "SYSTEM_CNF_NAO_ENCONTRADO"

    except Exception as erro:
        return f"ERRO: {erro}"


resultados = []

for arquivo in os.listdir(ORIGEM):
    if not arquivo.lower().endswith(".iso"):
        continue

    caminho = os.path.join(ORIGEM, arquivo)
    tamanho = os.path.getsize(caminho)

    resultados.append({
        "Arquivo": arquivo,
        "Game ID": extrair_id_iso(caminho),
        "Tamanho (MB)": round(tamanho / (1024 * 1024), 2),
    })

with open(RELATORIO, "w", newline="", encoding="utf-8-sig") as csvfile:
    campos = ["Arquivo", "Game ID", "Tamanho (MB)"]
    writer = csv.DictWriter(csvfile, fieldnames=campos, delimiter=";")
    writer.writeheader()
    writer.writerows(resultados)

print(f"Análise concluída: {len(resultados)} ISOs")
print(f"Relatório salvo em: {RELATORIO}")
