import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futdraw/components/button.dart';
import 'package:futdraw/components/modal.dart';
import 'package:futdraw/components/text_field.dart';
import 'package:futdraw/controllers/draw_controller.dart';
import 'package:futdraw/controllers/player_controller.dart';
import 'package:futdraw/models/player.dart';
import 'package:futdraw/utils/extensions.dart';
import 'package:futdraw/views/results_view.dart';
import 'package:provider/provider.dart';

class DrawView extends StatelessWidget {
  DrawView({super.key});
  final drawController = DrawController();
  int playersNumber = 0;

  @override
  Widget build(BuildContext context) {
    final playerController = Provider.of<PlayerController>(
      context,
      listen: false,
    );
    playerController.getAll();
    // playerController.getAll();
    // final int playersCount =
    //     playerController.players.where((p) => !p.ehGoleiro).length;
    // final int goalkeepersCount =
    //     playerController.players.where((p) => p.ehGoleiro).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Sortear jogadores')],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Sortear',
                  icon: Icons.sync,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => CustomModal(
                            titulo: 'Times',
                            content: _modalContent(
                              context,
                              playerController.players,
                            ),
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: playerController.getAll(),
        builder: (context, snapshot) {
          return snapshot.connectionState != ConnectionState.waiting
              ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Goleiros: ${snapshot.data!.where((p) => p.isGoalkeeper).length}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  '(Min: 2)',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Jogadores de linha: ${snapshot.data!.where((p) => !p.isGoalkeeper).length}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Image.asset(
                        'assets/images/sortear.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ],
                  ),
                ),
              )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  _modalContent(BuildContext context, List<Player> players) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextFormField(
          label: 'Quantidade de times',
          controller: TextEditingController(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            playersNumber = value.toInt();
          },
        ),
        const SizedBox(height: 15),
        CustomButton(
          text: 'Confirmar',
          icon: Icons.check,
          onPressed: () {
            final times = drawController.sortearTimesBalanceados(
              players,
              playersNumber,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultsView(sortedTeams: times),
              ),
            );
          },
        ),
      ],
    );
  }
}
