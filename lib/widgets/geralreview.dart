import 'package:flutter/material.dart';

class GeralReview extends StatelessWidget {
  final double valor;

  const GeralReview({Key? key, required this.valor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double valorValido = valor.clamp(0, 5.0);

    // Largura do termômetro com base no valor (1 a 5)
    final double largura = (valorValido / 5) * 300; // 300 é a largura máxima

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Média geral:${valorValido.toStringAsFixed(1)}"),
        Container(
          width: 300,
          height: 15,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: largura,
              height: 15,
              decoration: BoxDecoration(
                color: valorValido < 3 ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        Text(_subtitles(valor))
      ],
    );
  }

  String _subtitles(double grade) {
    if (grade < 1) {
      return "Não Avaliado";
    } else if (grade >= 1 && grade <= 2) {
      return "Ruim";
    } else if (grade > 2 && grade < 3) {
      return "Jogo ok";
    } else if (grade >= 3 && grade < 4) {
      return "Bom jogo";
    } else {
      return "Exelente";
    }
  }
}
