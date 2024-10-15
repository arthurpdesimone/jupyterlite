#!/bin/bash

# Função para exibir uma linha decorativa
print_separator() {
    echo "============================================="
}

# Cria um ambiente virtual e ativa-o
echo "🔄 Criando ambiente virtual..."
python3 -m venv venv
source venv/bin/activate
echo "✅ Ambiente virtual criado e ativado."

# Instala os pacotes necessários
echo "🔄 Instalando pacotes necessários..."
pip install jupyterlite-pyodide-kernel==0.4.2
pip install jupyterlite-core==0.4.0
pip install -r requirements.txt
echo "✅ Pacotes instalados."

# Define a URL e o nome do arquivo
PYODIDE_URL="https://github.com/pyodide/pyodide/releases/download/0.26.2/pyodide-0.26.2.tar.bz2"
FILE_NAME="pyodide-0.26.2.tar.bz2"

# Verifica se o arquivo já existe
if [ ! -f "$FILE_NAME" ]; then
    echo "🔽 Baixando pyodide..."
    wget $PYODIDE_URL
    
    # Verifica se o download foi bem-sucedido
    if [ -f "$FILE_NAME" ]; then
        echo "✅ Download bem-sucedido. Extraindo o arquivo..."
        
        # Extrai o arquivo
        tar -xvjf $FILE_NAME
        echo "✅ Extração concluída."
    else
        echo "❌ Falha no download."
        exit 1
    fi
else
    echo "ℹ️ $FILE_NAME já existe. Pulando o download."
fi

print_separator

# Constrói e serve o Jupyter Lite
echo "🔄 Construindo e servindo o Jupyter Lite..."
jupyter lite build
echo "✅ Jupyter Lite construído."

print_separator

# Copia os arquivos .whl do pyodide
SOURCE_DIRECTORY="pyodide"
DESTINATION_DIRECTORY="_output/"

echo "🔄 Verificando diretórios e copiando arquivos..."
# Verifica se o diretório de origem existe
if [ ! -d "$SOURCE_DIRECTORY" ]; then
    echo "❌ Diretório de origem '$SOURCE_DIRECTORY' não encontrado!"
    exit 1
fi

# Cria o diretório de destino se não existir
mkdir -p "$DESTINATION_DIRECTORY"

# Copia arquivos .whl do diretório de origem para o diretório de destino
find "$SOURCE_DIRECTORY" -type f -name "*.*" -exec cp {} "$DESTINATION_DIRECTORY" \;
echo "✅ Cópia concluída. Arquivos .whl copiados para '$DESTINATION_DIRECTORY'."

print_separator

# Função para substituir palavras em arquivos
replace_word() {
    local DIRECTORY=$1
    local SEARCH_WORD=$2
    local REPLACE_WORD=$3

    echo "🔄 Iniciando substituição de palavras..."
    
    # Verifica se o diretório existe
    if [ ! -d "$DIRECTORY" ]; then
        echo "❌ Diretório '$DIRECTORY' não encontrado!"
        exit 1
    fi

    # Loop através de todos os arquivos no diretório e suas subpastas
    find "$DIRECTORY" -type f | while read -r FILE; do
        echo "🔄 Processando $FILE..."
        # Substitui todas as ocorrências de search_word por replace_word no arquivo
        sed -i "s|$SEARCH_WORD|$REPLACE_WORD|g" "$FILE"
        echo "✅ Substituídas todas as ocorrências de '$SEARCH_WORD' por '$REPLACE_WORD' em '$FILE'."
    done
    echo "✅ Substituição concluída para todos os arquivos em '$DIRECTORY'."
}

# Primeira substituição
DIRECTORY=_output
SEARCH_WORD="https://cdn.jsdelivr.net/pyodide/v0.26.2/full/pyodide.js"
REPLACE_WORD="/pyodide.js"
replace_word "$DIRECTORY" "$SEARCH_WORD" "$REPLACE_WORD"

# Segunda substituição
SEARCH_WORD="https://cdn.jsdelivr.net/pyodide/v\\\${c.version}/full/"
REPLACE_WORD="/"
replace_word "$DIRECTORY" "$SEARCH_WORD" "$REPLACE_WORD"

print_separator

# Copia o pyodide.asm.js modificado
echo "🔄 Copiando pyodide.asm.js para '$DIRECTORY'..."
cp pyodide.asm.js $DIRECTORY/
echo "✅ Copiado com sucesso."

print_separator

# Inicia o Uvicorn
echo "🚀 Iniciando o servidor Uvicorn na porta 8000..."
uvicorn main:app --host 0.0.0.0 --port 8000 --reload