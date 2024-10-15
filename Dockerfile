# Usa a imagem base do Ubuntu
FROM ubuntu:20.04

# Define variáveis de ambiente para evitar prompts durante o apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Instala as dependências necessárias
RUN apt-get update && \
    apt-get install -y python3 python3-venv python3-pip wget tar uvicorn && \
    apt-get clean

# Define o diretório de trabalho no container
WORKDIR /app

# Copia o script shell para o container
COPY run.sh /app/run.sh

# Copia os outros arquivos necessários (requirements.txt, pyodide.asm.js, etc.)
COPY requirements.txt /app/requirements.txt
COPY pyodide.asm.js /app/pyodide.asm.js
COPY main.py /app/main.py

# Dá permissão de execução ao script
RUN chmod +x run.sh

RUN python3 -m pip install -r /app/requirements.txt

# Expõe a porta que o Uvicorn utilizará
EXPOSE 8000

# Define o ENTRYPOINT para rodar o servidor Uvicorn
ENTRYPOINT ["bash", "run.sh"]
