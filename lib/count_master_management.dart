import 'package:flutter/material.dart';

/// カウント項目を管理するページ
class CountMasterPage extends StatefulWidget {
  final List<String> counts;
  const CountMasterPage({super.key, required this.counts});

  @override
  State<CountMasterPage> createState() => _CountMasterPageState();
}

class _CountMasterPageState extends State<CountMasterPage> {
  late List<String> _counts;

  @override
  void initState() {
    super.initState();
    _counts = List.from(widget.counts);
  }

  void _addCount() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('項目を追加'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '項目名'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && !_counts.contains(name)) {
                setState(() => _counts.add(name));
              }
              Navigator.pop(context);
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _editCount(int index) {
    final controller = TextEditingController(text: _counts[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('項目を編集'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '項目名'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() => _counts[index] = name);
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _deleteCount(int index) {
    setState(() => _counts.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _counts);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('カウント項目管理'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _counts),
          ),
        ),
        body: ListView.builder(
          itemCount: _counts.length,
          itemBuilder: (context, index) {
            final c = _counts[index];
            return ListTile(
              title: Text(c),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editCount(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteCount(index),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addCount,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

