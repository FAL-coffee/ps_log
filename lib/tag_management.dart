import 'package:flutter/material.dart';

class TagManagementPage extends StatefulWidget {
  final List<String> tags;
  const TagManagementPage({super.key, required this.tags});

  @override
  State<TagManagementPage> createState() => _TagManagementPageState();
}

class _TagManagementPageState extends State<TagManagementPage> {
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.tags);
  }

  void _addTag() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タグを追加'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'タグ名'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && !_tags.contains(name)) {
                setState(() => _tags.add(name));
              }
              Navigator.pop(context);
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _editTag(int index) {
    final controller = TextEditingController(text: _tags[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タグを編集'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'タグ名'),
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
                setState(() => _tags[index] = name);
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _deleteTag(int index) {
    setState(() => _tags.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _tags);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('タグ管理'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _tags),
          ),
        ),
        body: ListView.builder(
          itemCount: _tags.length,
          itemBuilder: (context, index) {
            final tag = _tags[index];
            return ListTile(
              title: Text(tag),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editTag(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTag(index),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTag,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
