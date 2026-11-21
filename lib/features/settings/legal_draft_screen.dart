import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design_system/components.dart';
import '../../design_system/romanza_theme.dart';

class LegalDraftScreen extends StatefulWidget {
  const LegalDraftScreen({super.key, required this.privacy});
  final bool privacy;
  @override
  State<LegalDraftScreen> createState() => _LegalDraftScreenState();
}

class _LegalDraftScreenState extends State<LegalDraftScreen> {
  late final content = rootBundle.loadString(
    widget.privacy
        ? 'assets/legal/privacy_draft.txt'
        : 'assets/legal/terms_draft.txt',
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.privacy ? 'Privacidad · Borrador' : 'Términos · Borrador',
      ),
    ),
    body: SafeArea(
      top: false,
      child: FutureBuilder<String>(
        future: content,
        builder: (context, snapshot) => RomanzaPage(
          child: snapshot.hasData
              ? SelectableText(
                  snapshot.data!,
                  style: RomanzaType.body.copyWith(
                    fontSize: 16,
                    height: 24 / 16,
                  ),
                )
              : snapshot.hasError
              ? const Text(
                  'No pudimos abrir el documento. Vuelve a intentarlo.',
                )
              : const CircularProgressIndicator(),
        ),
      ),
    ),
  );
}
