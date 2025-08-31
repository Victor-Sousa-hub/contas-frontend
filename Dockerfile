# Usa uma imagem Node.js para o build
FROM node:18-alpine AS builder

WORKDIR /app

# Copia os arquivos de dependências
COPY package.json .
COPY package-lock.json .

# Instala as dependências de desenvolvimento e produção
RUN npm install

# Copia o restante do código do frontend
COPY . .

# Compila o projeto Vue para produção
# A variável de ambiente VUE_APP_API_URL é injetada aqui
RUN npm run build

# Imagem final para servir os arquivos estáticos
FROM nginx:1.23-alpine

# Copia os arquivos compilados do Vue para o diretório do Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Expõe a porta 80 do Nginx
EXPOSE 80

# Inicia o Nginx
CMD ["nginx", "-g", "daemon off;"]