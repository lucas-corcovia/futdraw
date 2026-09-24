# futdraw

A new Flutter project.

## API

O destino da API é definido na compilação por `API_BASE_URL`. Todos os clientes
REST usam esse endereço, inclusive o sorteio com IA.

No emulador Android, o comando abaixo usa o servidor local na porta 5020:

```bash
flutter run
```

Para acessar a API publicada no Render, informe a URL pública do serviço
(sem `/api` no final):

```bash
flutter run --dart-define=API_BASE_URL=https://SEU-SERVICO.onrender.com
flutter build apk --release --dart-define=API_BASE_URL=https://SEU-SERVICO.onrender.com
```

Para voltar ao modo local, execute `flutter run` sem o parâmetro. O endereço
padrão `http://10.0.2.2:5020` funciona no emulador Android. Em um dispositivo
físico, informe o IP da máquina que executa a API na rede local com
`--dart-define=API_BASE_URL=http://SEU-IP:5020`. A troca do destino exige uma
nova execução ou compilação do aplicativo.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
