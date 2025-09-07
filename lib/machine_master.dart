class Machine {
  final String name;
  final List<String> aliases;

  const Machine({required this.name, this.aliases = const []});
}

const List<Machine> machineMaster = [
  Machine(name: 'PF機動戦士ガンダムユニコーン', aliases: ['ユニコーン']),
  Machine(name: 'Pヴァルヴレイヴ', aliases: ['ヴヴヴ']),
  Machine(name: 'Sエヴァンゲリオン', aliases: ['エヴァ']),
];
