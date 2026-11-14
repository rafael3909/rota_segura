String _doisDigitos(int n) => n.toString().padLeft(2, '0');

/// Ex.: 13/11/2026 às 19:47
String formatarDataHora(DateTime data) {
  return '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year} '
      'às ${_doisDigitos(data.hour)}:${_doisDigitos(data.minute)}';
}

/// Ex.: 13/11/2026
String formatarData(DateTime data) {
  return '${_doisDigitos(data.day)}/${_doisDigitos(data.month)}/${data.year}';
}

/// Texto relativo amigável ("há 3 h", "há 2 dias").
/// [agora] pode ser injetado para tornar a função testável.
String tempoDecorrido(DateTime data, {DateTime? agora}) {
  final diff = (agora ?? DateTime.now()).difference(data);
  if (diff.inMinutes < 1) return 'agora mesmo';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  if (diff.inDays == 1) return 'há 1 dia';
  if (diff.inDays < 30) return 'há ${diff.inDays} dias';
  return 'em ${formatarData(data)}';
}
