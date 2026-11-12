cat << 'EOF' > install.sh
#!/bin/bash
set -e

echo "=== Instalador Automático UGREEN HiTune Max5c (Arch / CachyOS) ==="

# 1. Instalar dependências
echo "[1/5] Instalando dependências via pacman..."
sudo pacman -S --needed --noconfirm rust git base-devel bluez bluez-utils
sudo systemctl enable --now bluetooth

# 2. Clonar e compilar o ugreenapp
echo "[2/5] Clonando e compilando ugreen_core..."
rm -rf /tmp/ugreenapp
git clone https://github.com/dustincorder/ugreenapp.git /tmp/ugreenapp
cd /tmp/ugreenapp
cargo build --release
sudo cp /tmp/ugreenapp/target/release/ugreen_core /usr/local/bin/ugreen_core
rm -rf /tmp/ugreenapp

# 3. Detectar MAC do fone automaticamente via bluetoothctl
echo "[3/5] Buscando endereço MAC do UGREEN Max5c pareado..."
MAC=$(bluetoothctl devices | grep -i "Max5c" | awk '{print $2}' | head -n 1)

if [ -z "$MAC" ]; then
    read -p "Fone não encontrado nos dispositivos pareados. Digite o endereço MAC (ex: DE:50:B6:04:3C:A2): " MAC
else
    echo "Fone encontrado: $MAC"
fi

MAC_DBUS=$(echo "$MAC" | tr ':' '_')
DOCS_DIR=$(xdg-user-dir DOCUMENTS)
mkdir -p "$DOCS_DIR"

# 4. Criar script principal e atalho global 'fone'
echo "[4/5] Criando comando 'fone'..."
cat << INNER > "$DOCS_DIR/ugreen.sh"
#!/bin/bash
printf "scan\nconnect $MAC\nanc deep\neq classic\ngame on\nstatus\nexit\n" | ugreen_core
INNER
chmod +x "$DOCS_DIR/ugreen.sh"
sudo ln -sf "$DOCS_DIR/ugreen.sh" /usr/local/bin/fone

# 5. Criar monitorador D-Bus e serviço systemd
echo "[5/5] Configurando automação ao conectar Bluetooth..."
mkdir -p ~/.local/bin
cat << INNER > ~/.local/bin/ugreen-auto.sh
#!/bin/bash
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/bluez/hci0/dev_${MAC_DBUS}'" | \
while read -r line; do
  if [[ "\$line" == *"Connected"* ]]; then
    read -r next_line
    if [[ "\$next_line" == *"boolean true"* ]]; then
      sleep 2
      /usr/local/bin/fone
    fi
  fi
done
INNER
chmod +x ~/.local/bin/ugreen-auto.sh

mkdir -p ~/.config/systemd/user
cat << INNER > ~/.config/systemd/user/ugreen-auto.service
[Unit]
Description=Auto-configurar UGREEN Max5c ao conectar Bluetooth
After=bluetooth.target

[Service]
ExecStart=%h/.local/bin/ugreen-auto.sh
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
INNER

systemctl --user daemon-reload
systemctl --user enable --now ugreen-auto.service

echo "=== Concluído! Use o comando 'fone' no terminal ou apenas conecte seu fone no Bluetooth. ==="
EOF
chmod +x install.sh