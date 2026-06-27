String formatVnd(int amount) {
  final text = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(text[i]);
  }
  return buffer.toString();
}

String formatCountdown(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}

String bankDisplayName(String bankId) {
  return switch (bankId.toUpperCase()) {
    'TPB' => 'TPBank',
    'VCB' => 'Vietcombank',
    'MB' => 'MB Bank',
    'TCB' => 'Techcombank',
    'BIDV' => 'BIDV',
    _ => bankId,
  };
}
