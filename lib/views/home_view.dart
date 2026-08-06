import 'package:flutter/material.dart';
import 'package:futdraw/components/drawer.dart';
import 'package:futdraw/components/modal.dart';
import 'package:futdraw/components/widgets/add.group.dart';
import 'package:futdraw/components/widgets/infos.draw.teams.dart';
import 'package:futdraw/components/widgets/group.list.dart';
import 'package:futdraw/controllers/group_controller.dart';
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
        title: const Text('FutDraw'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showTeamLogicInfo,
            tooltip: 'Como os Times são Formados',
          ),
        ],
      ),
      drawer: const DrawerComponent(),
      body:
          _isLoading ? const Center(child: CircularProgressIndicator()) : const GroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGroup()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
