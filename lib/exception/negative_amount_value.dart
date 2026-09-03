class NegativeAmountValue implements Exception {
  final String message;

  NegativeAmountValue({required this.message});

  @override
  String toString() {
    return 'Valeur négatif entrée !\n $message';
  }
}