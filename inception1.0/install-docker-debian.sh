# 1) Remove possíveis pacotes conflitantes/antigos
sudo apt-get update
sudo apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc || true

# 2) Dependências para usar repositório HTTPS + chave GPG
sudo apt-get install -y ca-certificates curl gnupg

# 3) Adiciona a chave oficial da Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4) Adiciona o repositório da Docker para Debian
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5) Instala Docker Engine + Compose (plugin) + containerd
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6) (Opcional, recomendado) Permite usar docker sem sudo
sudo usermod -aG docker "$USER"
newgrp docker

# 7) Valida instalação
docker version
docker compose version
docker run --rm hello-world