import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

class CardDraft {
  final String question;
  final String answer;

  const CardDraft({required this.question, required this.answer});
}

class CardEditScreen extends StatefulWidget {
  final String title;
  final String question;
  final String answer;

  const CardEditScreen({
    super.key,
    this.title = 'Card',
    this.question = '',
    this.answer = '',
  });

  @override
  State<CardEditScreen> createState() => _CardEditScreenState();
}

class _CardEditScreenState extends State<CardEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _question;
  late final TextEditingController _answer;

  @override
  void initState() {
    super.initState();
    _question = TextEditingController(text: widget.question);
    _answer = TextEditingController(text: widget.answer);
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      CardDraft(
        question: _question.text.trim(),
        answer: _answer.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _question,
                    minLines: 2,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Question'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter a question'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _answer,
                    minLines: 3,
                    maxLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Answer'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter an answer'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Save', onPressed: _save),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}