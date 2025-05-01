import 'package:flutter/material.dart';
import 'package:futdraw/components/modal.dart';
import 'package:futdraw/components/widgets/add.many.players.dart';
import 'package:futdraw/components/widgets/infos.draw.teams.dart';
import 'package:futdraw/components/widgets/list.groups.dart';
import 'package:futdraw/models/group.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final List<Group> _groups = [];
  final bool _isLoading = false;

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

  void _showBatchAddPlayers() {
    showDialog(
      context: context,
      builder:
          (context) => CustomModal(
            titulo: 'Adicionar Vários Jogadores',
            content: AddManyPlayers(),
          ),
    );
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
          IconButton(
            icon: const Icon(Icons.sports_soccer),
            onPressed: () {},
            tooltip: 'Gerar Times',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GroupList(groups: _groups),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addMultiple',
            onPressed: _showBatchAddPlayers,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Theme.of(context).colorScheme.onTertiary,
            icon: const Icon(Icons.group_add),
            label: const Text('Vários Jogadores'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addOne',
            onPressed: () {},
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
