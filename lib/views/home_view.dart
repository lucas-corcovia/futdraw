import 'package:flutter/material.dart';
import 'package:futdraw/components/drawer.dart';
import 'package:futdraw/components/modal.dart';
import 'package:futdraw/components/widgets/add.group.dart';

import 'package:futdraw/components/widgets/infos.draw.teams.dart';
import 'package:futdraw/components/widgets/list.groups.dart';
import 'package:futdraw/controllers/group_controller.dart';
import 'package:futdraw/helpers/db_helper.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoading = true;

  void _showTeamLogicInfo() {
    showDialog(
      context: context,
      builder:
          (context) => CustomModal(
            titulo: 'Como os Times são Formados',
            content: InfoDrawTeams(),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupController>().getAll().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FutDraw - Sorteio de Times'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showTeamLogicInfo,
            tooltip: 'Informações',
          ),
          /*IconButton(
            icon: const Icon(Icons.sports_soccer),
            onPressed: () {},
            tooltip: 'Gerar Times',
          ), */
        ],
      ),
      drawer: DrawerComponent(),
      body:
          _isLoading ? Center(child: CircularProgressIndicator()) : GroupList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addOne',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddGroup()),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
