# ⚔️ Guardião do Ping - Sistema Tendão™

Um script de monitoramento de conexão para Windows, criado em `.bat`, com detecção de falhas, reconexão automática via Wi-Fi, e verificação inteligente para evitar falsos positivos.

> Ideal para manter a estabilidade em ambientes instáveis, automatizando a detecção e reconexão de rede.
> Para quem sofre com redes que só voltam a funcionar após reconectar.

---

## 🔧 Funcionalidades

- Monitora um IP (ex: `8.8.8.8`) via `ping`
- Detecta falhas com sistema de verificação dupla
- Reconecta automaticamente ao Wi-Fi atual
- Evita reconexão durante trocas de rede
- Mostra status em tempo real no terminal
- Design estilo “painel tático” com cores e informações úteis

---

## 🚀 Como usar

1. Clique com o botão direito no arquivo `guardiao.bat` e execute como **administrador**.
2. O script detecta automaticamente a rede atual e começa a monitorar.
3. Se detectar falhas consecutivas, tenta reconectar automaticamente.

---

## 📂 Estrutura do repositório

guardiao-do-ping/
├── guardiao.bat # Script principal
├── scripts/ # Outras versões (ex: PowerShell, Bash, etc.)
├── LOGS/ # Logs futuros ou eventos detectados
├── README.md # Este arquivo
└── LICENSE # Licença do projeto

yaml
Copiar
Editar

---

## 📄 Licença

MIT — use, modifique e compartilhe à vontade.