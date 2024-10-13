#!/bin/bash

# Cria um ambiente virtual e ativa-o
python3 -m venv venv
source venv/bin/activate

# Instala os pacotes necessários
#pip install jupyterlite-core==0.3.0
pip install jupyterlite-pyodide-kernel==0.4.2
pip install jupyterlite-core==0.4.0
pip install -r requirements.txt

# Define a URL e o nome do arquivo
PYODIDE_URL="https://github.com/pyodide/pyodide/releases/download/0.26.2/pyodide-0.26.2.tar.bz2"
FILE_NAME="pyodide-0.26.2.tar.bz2"

# Verifica se o arquivo já existe
if [ ! -f "$FILE_NAME" ]; then
    echo "Baixando pyodide..."
    wget $PYODIDE_URL
    
    # Verifica se o download foi bem-sucedido
    if [ -f "$FILE_NAME" ]; then
        echo "Download bem-sucedido. Extraindo o arquivo..."
        
        # Extrai o arquivo
        tar -xvjf $FILE_NAME
        
        echo "Extração concluída."
    else
        echo "Falha no download."
        exit 1
    fi
else
    echo "$FILE_NAME já existe. Pulando o download."
fi

# Constrói e serve o Jupyter Lite
jupyter lite build

# Copia o conteudo 
# Diretório de origem onde os arquivos .whl estão localizados
SOURCE_DIRECTORY="pyodide"

# Diretório de destino para onde os arquivos .whl serão copiados
DESTINATION_DIRECTORY="_output/"

# Verifica se o diretório de origem existe
if [ ! -d "$SOURCE_DIRECTORY" ]; then
    echo "Diretório de origem '$SOURCE_DIRECTORY' não encontrado!"
    exit 1
fi

# Cria o diretório de destino se não existir
mkdir -p "$DESTINATION_DIRECTORY"

# Copia arquivos .whl do diretório de origem para o diretório de destino
find "$SOURCE_DIRECTORY" -type f -name "*.*" -exec cp {} "$DESTINATION_DIRECTORY" \;

echo "Cópia concluída. Arquivos .whl foram copiados para '$DESTINATION_DIRECTORY'."


# Função para substituir palavras em arquivos
replace_word() {
    local DIRECTORY=$1
    local SEARCH_WORD=$2
    local REPLACE_WORD=$3

    # Verifica se o diretório existe
    if [ ! -d "$DIRECTORY" ]; then
        echo "Diretório '$DIRECTORY' não encontrado!"
        exit 1
    fi

    # Loop através de todos os arquivos no diretório e suas subpastas
    find "$DIRECTORY" -type f | while read -r FILE; do
        echo "Processando $FILE..."
        
        # Substitui todas as ocorrências de search_word por replace_word no arquivo
        sed -i "s|$SEARCH_WORD|$REPLACE_WORD|g" "$FILE"
        
        echo "Substituídas todas as ocorrências de '$SEARCH_WORD' por '$REPLACE_WORD' em '$FILE'."
    done
    echo "Substituição concluída para todos os arquivos em '$DIRECTORY' e suas subpastas."
}

# Atribui argumentos às variáveis
DIRECTORY=_output
SEARCH_WORD="https://cdn.jsdelivr.net/pyodide/v0.26.2/full/pyodide.js"
REPLACE_WORD="/pyodide.js"

# Chama a função replace_word
#replace_word "$DIRECTORY" "$SEARCH_WORD" "$REPLACE_WORD"

# Atribui argumentos às variáveis para a segunda substituição
DIRECTORY=_output
SEARCH_WORD="https://cdn.jsdelivr.net/pyodide/v\\\${c.version}/full/"
REPLACE_WORD="/"

# Chama a função replace_word novamente
#replace_word "$DIRECTORY" "$SEARCH_WORD" "$REPLACE_WORD"


# Inicia o jupyterlite
/home/pendragon/JavaScript/jupyterlite/venv/bin/python -m uvicorn main:app --reload 