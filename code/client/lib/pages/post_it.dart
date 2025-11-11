import 'package:flutter/material.dart';

class PostIt extends StatelessWidget {
  final Color color;
  final bool isImportant;
  final bool isReuniao;
  final String? dataReuniao;
  final String assunto;
  final VoidCallback onTap;

  const PostIt({
    super.key,
    required this.color,
    required this.isImportant,
    required this.isReuniao,
    required this.dataReuniao,
    required this.assunto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: 0.015,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.push_pin, color: Colors.red[700], size: 20),

              if (isImportant)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'IMPORTANTE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              if (isReuniao && dataReuniao != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'REUNIÃO: $dataReuniao',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF37474F),
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  assunto,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
