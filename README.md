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
flutter run --dart-define=API_BASE_URL=https://futdrawapi.onrender.com
flutter build apk --release --dart-define=API_BASE_URL=https://futdrawapi.onrender.com
```

Para voltar ao modo local, execute `flutter run` sem o parâmetro. O endereço
padrão `http://10.0.2.2:5020` funciona no emulador Android. Em um dispositivo
físico, informe o IP da máquina que executa a API na rede local com
`--dart-define=API_BASE_URL=http://SEU-IP:5020`. A troca do destino exige uma
nova execução ou compilação do aplicativo.

O APK fica em `build/app/outputs/flutter-apk/app-release.apk`. O cadastro
por e-mail e senha entra diretamente no app enquanto o envio de e-mails
estiver desativado na API. O sorteio com IA permanece oculto por padrão;
quando a API oferecer esse recurso, compile com `--dart-define=AI_ENABLED=true`.

O build Android atual usa a chave de debug mesmo em `--release`. Esse APK
serve para instalação e testes; configure uma chave própria antes de
publicar na Play Store. Para login Google, o cliente OAuth Android deve
cobrir o `applicationId` e a impressão SHA-1 da chave usada no APK, e o
cliente OAuth Web do app deve coincidir com `Google__ClientId` na API.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
