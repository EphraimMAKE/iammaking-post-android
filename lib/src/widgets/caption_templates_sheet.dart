import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Preset templates ──────────────────────────────────────────────────────────

const _templates = [
  _Template(
    emoji: '🚀',
    label: 'Lancement',
    text: '🚀 Excité de vous présenter [votre produit/service] !\n\nNous avons travaillé dur pour vous apporter quelque chose d\'exceptionnel. Découvrez-le maintenant 👇\n\n#lancement #nouveauté #iammaking',
  ),
  _Template(
    emoji: '💡',
    label: 'Conseil',
    text: '💡 Astuce du jour :\n\n[Votre conseil ici]\n\nEnregistrez ce post pour y revenir plus tard ! ♻️\n\n#conseil #tips #astuces',
  ),
  _Template(
    emoji: '📢',
    label: 'Annonce',
    text: '📢 Grande nouvelle !\n\n[Votre annonce ici]\n\nPartagez avec vos proches ! 🙌\n\n#annonce #news #actualité',
  ),
  _Template(
    emoji: '❓',
    label: 'Question',
    text: '❓ Question du jour :\n\n[Votre question ici]\n\nDites-nous en commentaire ! 👇\n\n#question #discussion #communauté',
  ),
  _Template(
    emoji: '🎉',
    label: 'Célébration',
    text: '🎉 On fête [votre événement] !\n\nMerci à toute notre communauté pour votre soutien 🙏\n\n#merci #milestone #communauté',
  ),
  _Template(
    emoji: '🛍️',
    label: 'Promotion',
    text: '🛍️ OFFRE SPÉCIALE !\n\n[Description de l\'offre]\n⏰ Valable jusqu\'au [date]\n\nLien en bio ! ⬆️\n\n#promo #offre #soldes',
  ),
  _Template(
    emoji: '📸',
    label: 'Coulisses',
    text: '📸 Dans les coulisses de [sujet] !\n\nVoici un aperçu de [description]\n\nQu\'en pensez-vous ? 👇\n\n#coulisses #behind #authentique',
  ),
  _Template(
    emoji: '🤝',
    label: 'Partenariat',
    text: '🤝 Fiers d\'annoncer notre partenariat avec @[partenaire] !\n\n[Description du partenariat]\n\nRestez connectés pour la suite ! 👀\n\n#partenariat #collaboration #together',
  ),
  _Template(
    emoji: '📊',
    label: 'Statistique',
    text: '📊 Chiffre de la semaine :\n\n[Votre stat] 🎯\n\nCe résultat nous motive à aller encore plus loin ! 💪\n\n#stats #performance #croissance',
  ),
  _Template(
    emoji: '💬',
    label: 'Témoignage',
    text: '"[Citation du client]"\n— [Prénom du client]\n\n✨ Merci pour votre confiance ! Vous aussi partagez votre expérience.\n\n#avis #témoignage #satisfaction',
  ),
];

class _Template {
  final String emoji;
  final String label;
  final String text;
  const _Template({required this.emoji, required this.label, required this.text});
}

// ── Public API ────────────────────────────────────────────────────────────────

Future<void> showCaptionTemplates(
  BuildContext context, {
  required void Function(String) onSelected,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CaptionTemplatesSheet(onSelected: onSelected),
  );
}

// ── Sheet widget ──────────────────────────────────────────────────────────────

class _CaptionTemplatesSheet extends StatefulWidget {
  final void Function(String) onSelected;
  const _CaptionTemplatesSheet({required this.onSelected});

  @override
  State<_CaptionTemplatesSheet> createState() => _CaptionTemplatesSheetState();
}

class _CaptionTemplatesSheetState extends State<_CaptionTemplatesSheet> {
  int? _preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: context.cBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.cBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: kPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Templates de captions',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.cText),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
        ),

        Divider(color: context.cBorder, height: 1),

        // List or preview
        Expanded(
          child: _preview != null
              ? _PreviewPane(
                  template: _templates[_preview!],
                  onUse: () {
                    widget.onSelected(_templates[_preview!].text);
                    Navigator.pop(context);
                  },
                  onBack: () => setState(() => _preview = null),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _templates.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, indent: 60, color: context.cBorder),
                  itemBuilder: (_, i) => ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(_templates[i].emoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    title: Text(
                      _templates[i].label,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.cText),
                    ),
                    subtitle: Text(
                      _templates[i].text
                          .replaceAll('\n', ' ')
                          .substring(
                              0,
                              _templates[i].text.length > 55
                                  ? 55
                                  : _templates[i].text.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: context.cMuted),
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      TextButton(
                        onPressed: () => setState(() => _preview = i),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Voir',
                            style:
                                TextStyle(fontSize: 12, color: kPrimary)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          widget.onSelected(_templates[i].text);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Utiliser',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ]),
                  ),
                ),
        ),
      ]),
    );
  }
}

class _PreviewPane extends StatelessWidget {
  final _Template template;
  final VoidCallback onUse;
  final VoidCallback onBack;

  const _PreviewPane({
    required this.template,
    required this.onUse,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
        ListTile(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
          ),
          title: Text(
            '${template.emoji}  ${template.label}',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: context.cText),
          ),
        ),
        Divider(height: 1, color: context.cBorder),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cBorder),
              ),
              child: Text(
                template.text,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: context.cText),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          child: ElevatedButton.icon(
            onPressed: onUse,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Utiliser ce template'),
          ),
        ),
      ]);
}
