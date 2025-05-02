import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:futdraw/models/player.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ResultsView extends StatelessWidget {
  ResultsView({super.key, required this.sortedTeams});
  final List<List<Player>> sortedTeams;
  final GlobalKey previewContainer = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Times Sorteados'),
            GestureDetector(
              child: Icon(Icons.camera_alt, size: 25),
              onTap: () {
                gerarImagemDosTimes(sortedTeams);
              },
            ),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RepaintBoundary(
        child: ListView.builder(
          itemCount: sortedTeams.length,
          itemBuilder: (context, index) {
            final time = sortedTeams[index];
            final somaNotas = time.fold(0.0, (sum, j) => sum + j.nota!);

            return Card(
              margin: EdgeInsets.all(12),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time ${index + 1}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),
                    ...time.map(
                      (j) => ListTile(
                        leading: Icon(
                          j.isGoalkeeper ? Icons.sports_soccer : Icons.person,
                        ),
                        title: Text(j.nome!),
                        subtitle: Text('Nota: ${j.nota!.toStringAsFixed(2)}'),
                        trailing:
                            j.isGoalkeeper
                                ? Text(
                                  '[G]',
                                  style: TextStyle(color: Colors.blue),
                                )
                                : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total: ${somaNotas.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> gerarImagemDosTimes(List<List<Player>> times) async {
    const width = 800;
    final height =
        100 + times.length * 250; // Aumentando o espaço entre os times

    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(245, 245, 245)); // Fundo suave

    final font = img.arial24;

    int y = 20;

    // Título centralizado
    img.drawString(
      image,
      'Times Sorteados',
      font: font,
      x: (width - 150) ~/ 2, // Centraliza o título
      y: y,
      color: img.ColorRgb8(0, 0, 0), // Azul
    );
    y += 50;

    for (int i = 0; i < times.length; i++) {
      final time = times[i];

      // Background para o título do time
      final tituloTime = 'Time ${i + 1}';
      final titleHeight = 30;
      final titleWidth = 200;
      final titleX = 20;
      final titleY = y;

      img.fillRect(
        image,
        x1: titleX - 5,
        y1: titleY - 5,
        x2: titleX - 120 + titleWidth,
        y2: titleY + titleHeight,
        color: img.ColorRgb8(200, 200, 200), // Cor de fundo azul claro
      );

      img.drawString(
        image,
        tituloTime,
        font: font,
        x: titleX,
        y: titleY,
        color: img.ColorRgb8(0, 0, 0), // Cor do texto do título
      );

      y += 40;

      // Fundo com borda para a lista de jogadores
      final blocoTop = y - 10;
      final blocoBottom = y + (time.length * 30);
      img.drawRect(
        image,
        x1: 10,
        y1: blocoTop,
        x2: width - 10,
        y2: blocoBottom,
        color: img.ColorRgb8(0, 0, 0),
        radius: 5,
      ); // Borda preta

      for (var jogador in time) {
        final notaStr = jogador.nota?.toStringAsFixed(2) ?? '0.0';
        final linha =
            '${jogador.nome} (${notaStr}) ${jogador.isGoalkeeper ? '[G]' : ''}'; // Icone de goleiro

        img.drawString(
          image,
          linha,
          font: font,
          x: 20,
          y: y,
          color: img.ColorRgb8(30, 30, 30), // Texto dos jogadores
        );
        y += 30;
      }

      y += 40; // Espaço entre os times
    }

    final pngBytes = Uint8List.fromList(img.encodePng(image));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/times_gerados.png');
    await file.writeAsBytes(pngBytes);

    print('Imagem criada em: ${file.path}');

    await OpenFile.open(file.path);
  }
}
