# UGREEN HiTune Max5c Auto-Config (CachyOS / Arch Linux)

Automação em Bash + systemd para conectar e configurar automaticamente o headset **UGREEN HiTune Max5c** no Linux utilizando o [ugreenapp](https://github.com/dustincorder/ugreenapp).

## O que este script faz
1. Instala as dependências (`rust`, `bluez`, `bluez-utils`, `base-devel`) e compila o `ugreen_core`.
2. Detecta o endereço MAC do seu fone já pareado no Bluetooth.
3. Cria o comando global `fone` para aplicar manualmente:
   - **ANC:** Deep (`anc deep`)
   - **Equalizador:** Classic (`eq classic`)
   - **Modo Jogo:** Ativado (`game on`)
4. Cria um serviço de usuário no `systemd` (`ugreen-auto.service`) que monitora o Bluetooth via `dbus-monitor` e aplica todas as configurações automaticamente 2 segundos após você ligar/conectar o fone.

## Pré-requisitos
- CachyOS, Arch Linux ou derivados.
- O fone **UGREEN HiTune Max5c** já deve estar pareado nas configurações de Bluetooth do sistema.

## Instalação

```bash
git clone [https://github.com/izaac-almeida/ugreen5c-fix.git](https://github.com/izaac-almeida/ugreen5c-fix.git)
cd ugreen5c-fix
chmod +x install.sh
./install.sh
```

## Uso manual
Para aplicar as configurações a qualquer momento pelo terminal:
```bash
fone
```

Para verificar o status do serviço automático:
```bash
systemctl --user status ugreen-auto.service
```
