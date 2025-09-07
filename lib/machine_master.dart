import 'package:flutter/material.dart';

/// 種別: パチンコ or スロット
enum MachineType { pachinko, slot }

/// 機種マスタデータ
class Machine {
  final MachineType type;
  final String name;
  final String manufacturer;
  final List<String> aliases;

  const Machine({
    required this.type,
    required this.name,
    required this.manufacturer,
    this.aliases = const [],
  });
}

/// サンプルマスタ
final List<Machine> machineMaster = [
  const Machine(
    type: MachineType.pachinko,
    name: 'PF機動戦士ガンダムユニコーン',
    manufacturer: 'SANKYO',
    aliases: ['ユニコーン'],
  ),
  const Machine(
    type: MachineType.pachinko,
    name: 'Pヴァルヴレイヴ',
    manufacturer: 'SANKYO',
    aliases: ['ヴヴヴ'],
  ),
  const Machine(
    type: MachineType.slot,
    name: 'Sエヴァンゲリオン',
    manufacturer: 'ビスティ',
    aliases: ['エヴァ'],
  ),
];

/// 機種マスタ管理ページ
class MachineMasterPage extends StatefulWidget {
  const MachineMasterPage({super.key});

  @override
  State<MachineMasterPage> createState() => _MachineMasterPageState();
}

class _MachineMasterPageState extends State<MachineMasterPage> {
  final List<Machine> _machines = machineMaster;
  final Set<String> _favoriteNames = {};

  void _addMachine() {
    MachineType type = MachineType.pachinko;
    final nameController = TextEditingController();
    final makerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('機種を追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<MachineType>(
                value: type,
                decoration: const InputDecoration(labelText: '種別'),
                items: const [
                  DropdownMenuItem(
                    value: MachineType.pachinko,
                    child: Text('パチンコ'),
                  ),
                  DropdownMenuItem(
                    value: MachineType.slot,
                    child: Text('スロット'),
                  ),
                ],
                onChanged: (v) => type = v ?? MachineType.pachinko,
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '名称'),
              ),
              TextField(
                controller: makerController,
                decoration: const InputDecoration(labelText: 'メーカー'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final maker = makerController.text.trim();
                if (name.isNotEmpty && maker.isNotEmpty) {
                  setState(() {
                    _machines.add(Machine(
                      type: type,
                      name: name,
                      manufacturer: maker,
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('追加'),
            )
          ],
        );
      },
    );
  }

  void _editMachine(int index) {
    var machine = _machines[index];
    MachineType type = machine.type;
    final nameController = TextEditingController(text: machine.name);
    final makerController = TextEditingController(text: machine.manufacturer);
    final oldName = machine.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('機種を編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<MachineType>(
                value: type,
                decoration: const InputDecoration(labelText: '種別'),
                items: const [
                  DropdownMenuItem(
                    value: MachineType.pachinko,
                    child: Text('パチンコ'),
                  ),
                  DropdownMenuItem(
                    value: MachineType.slot,
                    child: Text('スロット'),
                  ),
                ],
                onChanged: (v) => type = v ?? MachineType.pachinko,
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '名称'),
              ),
              TextField(
                controller: makerController,
                decoration: const InputDecoration(labelText: 'メーカー'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final maker = makerController.text.trim();
                if (name.isNotEmpty && maker.isNotEmpty) {
                  setState(() {
                    _machines[index] = Machine(
                      type: type,
                      name: name,
                      manufacturer: maker,
                    );
                    if (_favoriteNames.remove(oldName)) {
                      _favoriteNames.add(name);
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('保存'),
            )
          ],
        );
      },
    );
  }

  void _deleteMachine(int index) {
    final name = _machines[index].name;
    setState(() {
      _machines.removeAt(index);
      _favoriteNames.remove(name);
    });
  }

  void _toggleFavorite(String name) {
    setState(() {
      if (_favoriteNames.contains(name)) {
        _favoriteNames.remove(name);
      } else {
        _favoriteNames.add(name);
      }
    });
  }

  void _openFavorites() {
    final favorites =
        _machines.where((m) => _favoriteNames.contains(m.name)).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoriteMachinePage(
          favorites: favorites,
          onRemove: (name) {
            _toggleFavorite(name);
          },
        ),
      ),
    );
  }

  String _typeLabel(MachineType type) =>
      type == MachineType.pachinko ? 'パチンコ' : 'スロット';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('機種マスタ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _openFavorites,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _machines.length,
        itemBuilder: (context, index) {
          final m = _machines[index];
          final isFav = _favoriteNames.contains(m.name);
          return ListTile(
            title: Text(m.name),
            subtitle: Text('${_typeLabel(m.type)} / ${m.manufacturer}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isFav ? Icons.star : Icons.star_border),
                  onPressed: () => _toggleFavorite(m.name),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editMachine(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteMachine(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMachine,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// お気に入り機種一覧ページ
class FavoriteMachinePage extends StatelessWidget {
  const FavoriteMachinePage({
    super.key,
    required this.favorites,
    required this.onRemove,
  });

  final List<Machine> favorites;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り機種'),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('お気に入りはありません'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final m = favorites[index];
                return ListTile(
                  title: Text(m.name),
                  subtitle: Text(m.manufacturer),
                  trailing: IconButton(
                    icon: const Icon(Icons.star),
                    onPressed: () {
                      onRemove(m.name);
                    },
                  ),
                );
              },
            ),
    );
  }
}
