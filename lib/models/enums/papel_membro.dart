enum PapelMembro {
  dono,
  admin,
  membro;

  static PapelMembro fromIndex(int i) => PapelMembro.values[i];

  String get label => switch (this) {
    PapelMembro.dono => 'Dono',
    PapelMembro.admin => 'Admin',
    PapelMembro.membro => 'Membro',
  };
}
